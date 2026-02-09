//
//  BridgeMessage.swift
//  WatchConnectivityDemo
//

import Foundation

public struct BridgeMessage: Codable, Sendable, Identifiable {
    public let id: UUID
    public let text: String
    public let origin: String
    public let timestamp: Date
    
    public init(text: String, origin: String, timestamp: Date = Date(), id: UUID = UUID()) {
        self.id = id
        self.text = text
        self.origin = origin
        self.timestamp = timestamp
    }
}
