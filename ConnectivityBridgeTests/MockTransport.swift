//
//  MockTransport.swift
//  WatchConnectivityDemo
//
//  Created by David Thorn on 09.02.26.
//

import Foundation
import ConnectivityBridge

final class MockTransport: WatchConnectivityBridging, @unchecked Sendable {
    private let state = State()

    func setPeer(_ peer: MockTransport) async {
        await state.setPeer(peer)
    }

    func connect() {}

    func send<T: Codable & Sendable & Identifiable>(_ value: T) async {
        await state.yieldSnapshot(sent: value, received: nil)
        if let peer = await state.peer {
            await peer.receive(value)
        }
    }

    func stream<T: Codable & Sendable & Identifiable>(as type: T.Type) async -> AsyncStream<ConnectionSnapshot<T>> {
        await state.stream(as: type)
    }

    private func receive<T: Codable & Sendable & Identifiable>(_ value: T) async {
        await state.yieldSnapshot(sent: nil, received: value)
    }

    private actor State {
        var peer: MockTransport?
        var continuations: [ObjectIdentifier: Any] = [:]
        var lastSnapshots: [ObjectIdentifier: Any] = [:]

        func setPeer(_ peer: MockTransport) {
            self.peer = peer
        }

        func stream<T: Codable & Sendable & Identifiable>(as type: T.Type) -> AsyncStream<ConnectionSnapshot<T>> {
            AsyncStream { continuation in
                let id = ObjectIdentifier(T.self)
                continuations[id] = ContinuationBox(continuation)
                if let last = lastSnapshots[id] as? ConnectionSnapshot<T> {
                    continuation.yield(last)
                } else {
                    continuation.yield(ConnectionSnapshot<T>.initial)
                }
                continuation.onTermination = { _ in
                    Task { await self.removeContinuation(id: id) }
                }
            }
        }

        func yieldSnapshot<T: Codable & Sendable & Identifiable>(sent: T?, received: T?) {
            let id = ObjectIdentifier(T.self)
            let snapshot = ConnectionSnapshot(
                connectable: true,
                isReachable: true,
                isAppInstalled: true,
                canSendMessage: true,
                received: received,
                sent: sent
            )
            lastSnapshots[id] = snapshot
            if let box = continuations[id] as? ContinuationBox<T> {
                box.continuation.yield(snapshot)
            }
        }

        private func removeContinuation(id: ObjectIdentifier) {
            continuations.removeValue(forKey: id)
        }
    }
}
