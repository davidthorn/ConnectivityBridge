//
//  Envelope.swift
//  WatchConnectivityDemo
//

import Foundation

public struct Envelope<Payload: Codable & Sendable & Identifiable>: Codable, Sendable, Identifiable{
    public enum Kind: String, Codable, Sendable {
        case request
        case reply
    }
    
    public let id: UUID
    public let kind: Kind
    public let payload: Payload
    
    public init(id: UUID, kind: Kind, payload: Payload) {
        self.id = id
        self.kind = kind
        self.payload = payload
    }
}
