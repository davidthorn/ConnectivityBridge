//
//  WatchConnectivityBridge.swift
//  WatchConnectivityDemo
//
//  Created by David Thorn on 06.02.26.
//

import Foundation
import WatchConnectivity

public final class WatchConnectivityBridge: NSObject, WatchConnectivityBridging, Sendable {
    public var platformName: String {
        #if os(iOS)
            return "iOS"
        #elseif os(watchOS)
            return "watchOS"
        #else
            return "unknown"
        #endif
    }
    
    private let store: ConnectionStore
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public override init() {
        self.store = ConnectionStore(initial: .initial)
        super.init()
    }
    
    public static let shared = WatchConnectivityBridge()
    
    public var isSupported: Bool {
        #if os(iOS)
        return WCSession.isSupported()
        #elseif os(watchOS)
        return true
        #else
        return false
        #endif
    }
    
    public func connect() {
        guard isSupported else { return }
        let session = WCSession.default
        guard session.delegate == nil else { return }
        session.delegate = self
        session.activate()
        Task { await pushSnapshot() }
    }
    
    public var isReachable: Bool {
        WCSession.default.activationState == .activated && WCSession.default.isReachable
    }
    
    public var canSendMessage: Bool {
        guard isAppInstalled && isReachable else { return false }
        #if os(iOS)
        return isPaired
        #else
        return true
        #endif
    }
    
    public var isAppInstalled: Bool {
        #if os(iOS)
        return isWatchAppInstalled
        #elseif os(watchOS)
        return isCompanionAppInstalled
        #else
        return false
        #endif
    }
    
    #if os(iOS)
    public var isPaired: Bool {
        WCSession.default.isPaired
    }
    
    public var isWatchAppInstalled: Bool {
        WCSession.default.isWatchAppInstalled
    }
    
    #endif
    
    #if os(watchOS)
    public var isCompanionAppInstalled: Bool {
        WCSession.default.isCompanionAppInstalled
    }
    #endif
    
    public func send<T: Codable & Sendable & Identifiable>(_ value: T) async throws {
        guard canSendMessage else { throw BridgeError.cannotSend }
        let session = WCSession.default
        let data: Data
        do {
            data = try encoder.encode(value)
        } catch {
            throw BridgeError.encodingFailed
        }
        await pushSnapshot(sentData: data)
        
        try await withCheckedThrowingContinuation { continuation in
            session.sendMessageData(data) { _ in
                // We intentionally ignore the reply payload here. Our app protocol always sends
                // a separate reply message, and the peer calls replyHandler(Data()) in
                // WCSessionDelegate.session(_:didReceiveMessageData:replyHandler:), so this
                // completion fires for every delivered message. We only use it to signal
                // that the send succeeded.
                continuation.resume()
            } errorHandler: { error in
                continuation.resume(throwing: BridgeError.sendFailed(error.localizedDescription))
            }
        }
    }
    
    public func stream<T: Codable & Sendable & Identifiable>(as type: T.Type) async -> AsyncStream<ConnectionSnapshot<T>> {
        await pushSnapshot()
        let rawStream = await store.stream()
        let decodeSnapshot: @Sendable (RawSnapshot, T.Type) -> ConnectionSnapshot<T> = decodeSnapshot
        return AsyncStream { continuation in
            let task = Task {
                for await raw in rawStream {
                    continuation.yield(decodeSnapshot(raw, T.self))
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    private func decodeSnapshot<T: Codable & Sendable & Identifiable>(_ raw: RawSnapshot, as type: T.Type) -> ConnectionSnapshot<T> {
        let sent = raw.sentData.flatMap { try? decoder.decode(T.self, from: $0) }
        let received = raw.receivedData.flatMap { try? decoder.decode(T.self, from: $0) }
        return ConnectionSnapshot(
            connectable: raw.connectable,
            isReachable: raw.isReachable,
            isAppInstalled: raw.isAppInstalled,
            canSendMessage: raw.canSendMessage,
            received: received,
            sent: sent
        )
    }
    
    private func pushSnapshot(connectable: Bool? = nil, receivedData: Data? = nil, sentData: Data? = nil) async {
        let current = await store.current()
        let flags = currentFlags()
        let snapshot = RawSnapshot(
            connectable: connectable ?? current.connectable,
            isReachable: flags.isReachable,
            isAppInstalled: flags.isAppInstalled,
            canSendMessage: flags.canSendMessage,
            receivedData: receivedData ?? current.receivedData,
            sentData: sentData ?? current.sentData
        )
        await store.update(snapshot)
    }
    
    private func currentFlags() -> (isReachable: Bool, isAppInstalled: Bool, canSendMessage: Bool) {
        let reachable = isReachable
        let installed = isAppInstalled
        let canSend = canSendMessage
        return (reachable, installed, canSend)
    }
}

extension WatchConnectivityBridge: WCSessionDelegate {
    #if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        Task {
            await self.pushSnapshot(connectable: false)
        }
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
        Task {
            await self.pushSnapshot(connectable: false)
        }
    }
    #endif
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        Task {
            let isConnected: Bool
            switch activationState {
            case .activated:
                isConnected = true
            default:
                isConnected = false
            }
            await self.pushSnapshot(connectable: isConnected)
        }
    }
    
    public func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        Task {
            await self.pushSnapshot(receivedData: messageData)
        }
        // Always acknowledge receipt. Our sender awaits the WCSession success callback
        // and does not depend on a reply payload, so we return empty Data to complete
        // the handshake and keep send() from timing out.
        replyHandler(Data())
    }

    public func sessionReachabilityDidChange(_ session: WCSession) {
        Task {
            await self.pushSnapshot()
        }
    }
}
