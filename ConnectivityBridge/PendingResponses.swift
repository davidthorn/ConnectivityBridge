//
//  PendingResponses.swift
//  WatchConnectivityDemo
//
//  Created by David Thorn on 08.02.26.
//

import Foundation

actor PendingResponses<Response: Codable & Sendable & Identifiable> {
    private var continuations: [UUID: CheckedContinuation<Response, Error>] = [:]
    private var timeouts: [UUID: Task<Void, Never>] = [:]
    
    func store(id: UUID, continuation: CheckedContinuation<Response, Error>, timeoutTask: Task<Void, Never>) {
        continuations[id] = continuation
        timeouts[id] = timeoutTask
    }
    
    func isPending(id: UUID) -> Bool {
        continuations[id] != nil
    }
    
    func resolve(id: UUID, value: Response) {
        timeouts.removeValue(forKey: id)?.cancel()
        guard let continuation = continuations.removeValue(forKey: id) else { return }
        continuation.resume(returning: value)
    }
    
    func timeout(id: UUID) {
        timeouts.removeValue(forKey: id)?.cancel()
        guard let continuation = continuations.removeValue(forKey: id) else { return }
        continuation.resume(throwing: BridgeError.timeout(id))
    }
}
