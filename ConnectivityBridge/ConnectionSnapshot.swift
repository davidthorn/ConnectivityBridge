//
//  ConnectionSnapshot.swift
//  WatchConnectivityDemo
//
//  Created by David Thorn on 08.02.26.
//

import Foundation

public struct ConnectionSnapshot<T: Codable & Sendable & Identifiable>: Sendable {
    public var connectable: Bool
    public var isReachable: Bool
    public var isAppInstalled: Bool
    public var canSendMessage: Bool
    public var received: T?
    public var sent: T?
    
    public init(
        connectable: Bool,
        isReachable: Bool,
        isAppInstalled: Bool,
        canSendMessage: Bool,
        received: T?,
        sent: T?
    ) {
        self.connectable = connectable
        self.isReachable = isReachable
        self.isAppInstalled = isAppInstalled
        self.canSendMessage = canSendMessage
        self.received = received
        self.sent = sent
    }
    
    public static var initial: ConnectionSnapshot<T> {
        ConnectionSnapshot(
            connectable: false,
            isReachable: false,
            isAppInstalled: false,
            canSendMessage: false,
            received: nil,
            sent: nil
        )
    }
}

extension ConnectionSnapshot: Equatable where T: Equatable {}
