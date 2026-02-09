//
//  ConnectionStatus.swift
//  WatchConnectivityDemo
//
//  Created by David Thorn on 09.02.26.
//

import Foundation

public struct ConnectionStatus: Sendable, Equatable {
    public let connectable: Bool
    public let isReachable: Bool
    public let isAppInstalled: Bool
    public let canSendMessage: Bool

    public init(connectable: Bool, isReachable: Bool, isAppInstalled: Bool, canSendMessage: Bool) {
        self.connectable = connectable
        self.isReachable = isReachable
        self.isAppInstalled = isAppInstalled
        self.canSendMessage = canSendMessage
    }
}
