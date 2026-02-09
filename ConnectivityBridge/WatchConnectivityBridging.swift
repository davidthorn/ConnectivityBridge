//
//  WatchConnectivityBridging.swift
//  WatchConnectivityDemo
//
//  Created by David Thorn on 08.02.26.
//

public protocol WatchConnectivityBridging: AnyObject, Sendable {
    /// Activates the underlying WatchConnectivity session.
    /// Call this as early as possible (AppDelegate on iOS, App init on watchOS).
    func connect()

    /// Sends a typed payload to the paired device.
    /// - Parameter value: The payload to encode and transmit.
    /// - Throws: `BridgeError.cannotSend` if the session cannot send,
    ///           `BridgeError.encodingFailed` if encoding fails,
    ///           `BridgeError.sendFailed` when WCSession reports an error.
    func send<T: Codable & Sendable & Identifiable>(_ value: T) async throws
    
    /// Streams connection snapshots for the given payload type.
    /// The stream yields the latest connection flags and the most recent sent/received payload.
    /// - Parameter type: The payload type to decode.
    /// - Returns: An async stream of `ConnectionSnapshot<T>`.
    func stream<T: Codable & Sendable & Identifiable>(as type: T.Type) async -> AsyncStream<ConnectionSnapshot<T>>
}
