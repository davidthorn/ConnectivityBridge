//
//  BridgeError.swift
//  WatchConnectivityDemo
//
//  Created by David Thorn on 08.02.26.
//

import Foundation

public enum BridgeError: Error, Sendable {
    case timeout(UUID)
}
