//
//  RequestsStream.swift
//  WatchConnectivityDemo
//
//  Created by David Thorn on 08.02.26.
//

import Foundation

actor RequestsStream<T: Sendable> {
    private var continuation: AsyncStream<T>.Continuation?
    private var buffer: [T] = []

    func stream() -> AsyncStream<T> {
        AsyncStream { continuation in
            self.continuation = continuation
            if !buffer.isEmpty {
                for value in buffer {
                    continuation.yield(value)
                }
                buffer.removeAll()
            }
            continuation.onTermination = { _ in
                Task { await self.clearContinuation() }
            }
        }
    }

    func yield(_ value: T) {
        if let continuation {
            continuation.yield(value)
        } else {
            buffer.append(value)
        }
    }

    private func clearContinuation() {
        continuation = nil
    }
}
