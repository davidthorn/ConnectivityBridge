//
//  ContinuationBox.swift
//  WatchConnectivityDemo
//
//  Created by David Thorn on 09.02.26.
//

import Foundation
import ConnectivityBridge

final class ContinuationBox<T: Codable & Sendable & Identifiable>: @unchecked Sendable {
    let continuation: AsyncStream<ConnectionSnapshot<T>>.Continuation
    init(_ continuation: AsyncStream<ConnectionSnapshot<T>>.Continuation) {
        self.continuation = continuation
    }
}
