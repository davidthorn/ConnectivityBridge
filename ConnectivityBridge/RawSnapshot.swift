//
//  RawSnapshot.swift
//  WatchConnectivityDemo
//
//  Created by David Thorn on 09.02.26.
//

import Foundation

struct RawSnapshot: Sendable {
    var connectable: Bool
    var isReachable: Bool
    var isAppInstalled: Bool
    var canSendMessage: Bool
    var receivedData: Data?
    var sentData: Data?
    
    static let initial = RawSnapshot(
        connectable: false,
        isReachable: false,
        isAppInstalled: false,
        canSendMessage: false,
        receivedData: nil,
        sentData: nil
    )
}
