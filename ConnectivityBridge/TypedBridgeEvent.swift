//
//  TypedBridgeEvent.swift
//  WatchConnectivityDemo
//

import Foundation

public enum TypedBridgeEvent<Request: Codable & Sendable & Identifiable, Response: Codable & Sendable & Identifiable>: Sendable {
    case sentRequest(Request, id: UUID, date: Date)
    case receivedRequest(Request, id: UUID, date: Date)
    case sentReply(Response, id: UUID, date: Date)
    case receivedReply(Response, id: UUID, date: Date)
    case timeout(id: UUID, date: Date)
    case statusChanged(ConnectionStatus, date: Date)
}
