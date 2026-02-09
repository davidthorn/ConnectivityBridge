//
//  TypedConnectivityBridging.swift
//  WatchConnectivityDemo
//

import Foundation

public protocol TypedConnectivityBridging: Actor {
    associatedtype Request: Codable & Sendable & Identifiable
    associatedtype Response: Codable & Sendable & Identifiable
    
    /// Activates the underlying WatchConnectivity session.
    /// Call this as early as possible (AppDelegate on iOS, App init on watchOS).
    func connect()

    /// Stream of incoming requests that expect a reply.
    /// - Returns: An async stream of request contexts containing the payload and correlation id.
    func requests() async -> AsyncStream<TypedConnectivityBridge<Request, Response>.RequestContext>

    /// Stream of bridge-level events (send, receive, timeout, status changes).
    /// - Returns: An async stream of typed bridge events.
    func events() async -> AsyncStream<TypedBridgeEvent<Request, Response>>

    /// Sends a request and awaits the correlated response.
    /// - Parameters:
    ///   - payload: The request payload to encode and send.
    ///   - timeout: The maximum time to wait for a reply.
    /// - Returns: The decoded response payload.
    /// - Throws: `BridgeError.timeout` if no reply arrives in time, or send/encode errors.
    func request(_ payload: Request, timeout: Duration) async throws -> Response

    /// Sends a request without awaiting a reply.
    /// - Parameter payload: The request payload to encode and send.
    /// - Throws: `BridgeError.cannotSend`, `BridgeError.encodingFailed`, or `BridgeError.sendFailed`.
    func send(_ payload: Request) async throws

    /// Replies to a previously received request.
    /// - Parameters:
    ///   - id: The correlation id from the incoming request context.
    ///   - response: The response payload to send.
    func reply(to id: UUID, with response: Response) async

    /// Cancels any internal tasks and stops listening for messages.
    func shutdown()
}
