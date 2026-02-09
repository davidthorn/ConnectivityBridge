//
//  EventsStream.swift
//  WatchConnectivityDemo
//

import Foundation

actor EventsStream<T: Sendable> {
    private var continuation: AsyncStream<T>.Continuation?
    private var buffer: [T] = []
    private let maxBuffer: Int

    init(maxBuffer: Int = 200) {
        self.maxBuffer = max(1, maxBuffer)
    }

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
            if buffer.count > maxBuffer {
                buffer.removeFirst(buffer.count - maxBuffer)
            }
        }
    }

    private func clearContinuation() {
        continuation = nil
    }
}
