//
//  TypedConnectivityBridging.swift
//  WatchConnectivityDemo
//

import Foundation

public protocol TypedConnectivityBridging: Actor {
    associatedtype Request: Codable & Sendable & Identifiable
    associatedtype Response: Codable & Sendable & Identifiable
    
    func connect()
    func requests() async -> AsyncStream<TypedConnectivityBridge<Request, Response>.RequestContext>
    func events() async -> AsyncStream<TypedBridgeEvent<Request, Response>>
    func request(_ payload: Request, timeout: Duration) async throws -> Response
    func send(_ payload: Request) async
    func reply(to id: UUID, with response: Response) async
    func shutdown()
}
