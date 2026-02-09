//
//  EmptyResponse.swift
//  WatchConnectivityDemo
//

import Foundation

public struct EmptyResponse: Codable, Sendable, Identifiable {
    public let id: UUID
    
    public init(id: UUID = UUID()) {
        self.id = id
    }
}
