//
//  ConnectionStore.swift
//  WatchConnectivityDemo
//
//  Created by David Thorn on 08.02.26.
//

import Foundation

actor ConnectionStore {
    private var snapshot: RawSnapshot
    private var continuations: [UUID: AsyncStream<RawSnapshot>.Continuation] = [:]
    
    init(initial: RawSnapshot) {
        self.snapshot = initial
    }
    
    func stream() -> AsyncStream<RawSnapshot> {
        AsyncStream { continuation in
            let id = UUID()
            continuations[id] = continuation
            continuation.yield(self.snapshot)
            continuation.onTermination = { _ in
                Task { await self.removeContinuation(id: id) }
            }
        }
    }
    
    func current() -> RawSnapshot {
        snapshot
    }
    
    func update(_ newSnapshot: RawSnapshot) {
        snapshot = newSnapshot
        for continuation in continuations.values {
            continuation.yield(newSnapshot)
        }
    }
    
    private func removeContinuation(id: UUID) {
        continuations.removeValue(forKey: id)
    }
}
