//
//  WatchViewModel.swift
//  WatchConnectivityDemo Watch App
//

import SwiftUI
import Combine
import ConnectivityBridge

@MainActor
final class WatchViewModel: ObservableObject {
    private let maxLogItems = 60

    @Published var snapshot: ConnectionSnapshot<BridgeMessage> = .initial
    @Published var logs: [CommLogItem] = []
    @Published var sendPulse: Bool = false
    @Published var replyPulse: Bool = false
    @Published var lastRequestText: String?
    @Published var lastReplyText: String?
    @Published var pendingUntil: Date?
    @Published var lastStatus: String?

    private let bridge: TypedConnectivityBridge<BridgeMessage, BridgeMessage>
    private var recentLogKeys: [String] = []
    private var recentLogKeySet: Set<String> = []

    init(bridge: TypedConnectivityBridge<BridgeMessage, BridgeMessage>) {
        self.bridge = bridge
    }

    func observe() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.observeStream() }
            group.addTask { await self.observeRequests() }
            group.addTask { await self.observeEvents() }
            await group.waitForAll()
        }
    }

    func observeStream() async {
        let stream = await bridge.stream()
        for await state in stream {
            if Task.isCancelled { break }
            snapshot = state
        }
    }

    func observeRequests() async {
        let requests = await bridge.requests()
        for await request in requests {
            if Task.isCancelled { break }
            let reply = BridgeMessage(text: "Reply from Watch", origin: "Watch", id: request.payload.id)
            await bridge.reply(to: request.id, with: reply)
        }
    }

    func observeEvents() async {
        let events = await bridge.events()
        for await event in events {
            if Task.isCancelled { break }
            switch event {
            case let .sentRequest(payload, _, date):
                appendLog(CommLogItem(direction: .sent, kind: .request, message: payload.text, timestamp: date, messageId: payload.id))
            case let .receivedRequest(payload, _, date):
                appendLog(CommLogItem(direction: .received, kind: .request, message: payload.text, timestamp: date, messageId: payload.id))
            case let .sentReply(payload, _, date):
                markMatched(payload.id)
                appendLog(CommLogItem(direction: .sent, kind: .reply, message: payload.text, timestamp: date, messageId: payload.id, isMatched: true))
            case let .receivedReply(payload, _, date):
                markMatched(payload.id)
                appendLog(CommLogItem(direction: .received, kind: .reply, message: payload.text, timestamp: date, messageId: payload.id, isMatched: true))
            case let .timeout(id, date):
                appendLog(CommLogItem(direction: .received, kind: .reply, message: "Reply timed out", timestamp: date, messageId: id))
            case let .statusChanged(status, date):
                appendLog(CommLogItem(direction: .received, kind: .system, message: statusMessage(status), timestamp: date, messageId: UUID()))
            @unknown default:
                break
            }
        }
    }

    func sendPrimaryRequest() async {
        await sendRequest(text: "Hello from the watch app", timeout: 5)
    }

    func sendReplyRequest() async {
        await sendRequest(text: "Requesting a reply from the phone", timeout: 2)
    }

    func sendQuickRequest() async {
        await sendRequest(text: "Hello from the watch app", timeout: 2)
    }

    private func sendRequest(text: String, timeout: Int) async {
        let requestId = UUID()
        let message = BridgeMessage(text: text, origin: "Watch", id: requestId)
        lastRequestText = message.text
        pendingUntil = Date().addingTimeInterval(TimeInterval(timeout))
        lastStatus = nil
        await pulseSend()

        do {
            let response = try await bridge.request(message, timeout: .seconds(timeout))
            lastReplyText = response.text
            pendingUntil = nil
            lastStatus = "Reply received"
            await pulseReply()
        } catch {
            pendingUntil = nil
            if let bridgeError = error as? BridgeError, case .timeout = bridgeError {
                lastStatus = "Reply timed out"
            } else {
                lastStatus = "Send failed"
            }
        }
    }

    private func pulseSend() async {
        guard !sendPulse else { return }
        withAnimation(.easeInOut(duration: 0.18)) {
            sendPulse = true
        }
        try? await Task.sleep(nanoseconds: 250_000_000)
        withAnimation(.easeInOut(duration: 0.22)) {
            sendPulse = false
        }
    }

    private func pulseReply() async {
        guard !replyPulse else { return }
        withAnimation(.easeInOut(duration: 0.18)) {
            replyPulse = true
        }
        try? await Task.sleep(nanoseconds: 250_000_000)
        withAnimation(.easeInOut(duration: 0.22)) {
            replyPulse = false
        }
    }

    private func appendLog(_ item: CommLogItem) {
        let key = logKey(for: item)
        if recentLogKeySet.contains(key) { return }
        recentLogKeySet.insert(key)
        recentLogKeys.append(key)
        logs.append(item)
        if logs.count > maxLogItems {
            let excess = logs.count - maxLogItems
            logs.removeFirst(excess)
            recentLogKeys.removeFirst(min(excess, recentLogKeys.count))
            recentLogKeySet = Set(recentLogKeys)
        }
    }

    private func logKey(for item: CommLogItem) -> String {
        "\(item.messageId.uuidString)-\(item.kind)-\(item.direction)"
    }

    private func markMatched(_ id: UUID) {
        if logs.contains(where: { $0.messageId == id && $0.kind == .request }) {
            logs = logs.map { item in
                if item.messageId == id && item.kind == .request {
                    return CommLogItem(
                        direction: item.direction,
                        kind: item.kind,
                        message: item.message,
                        timestamp: item.timestamp,
                        messageId: item.messageId,
                        isMatched: true
                    )
                }
                return item
            }
        }
    }

    private func statusMessage(_ status: ConnectionStatus) -> String {
        let connectable = status.connectable ? "Connected" : "Not connected"
        let reachable = status.isReachable ? "Reachable" : "Not reachable"
        let installed = status.isAppInstalled ? "App installed" : "App not installed"
        let canSend = status.canSendMessage ? "Can send" : "Cannot send"
        return "\(connectable) • \(reachable) • \(installed) • \(canSend)"
    }

    func clearLogs() {
        logs.removeAll()
        recentLogKeys.removeAll()
        recentLogKeySet.removeAll()
    }
}
