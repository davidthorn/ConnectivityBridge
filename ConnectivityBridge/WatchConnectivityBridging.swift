//
//  WatchConnectivityBridging.swift
//  WatchConnectivityDemo
//
//  Created by David Thorn on 08.02.26.
//

public protocol WatchConnectivityBridging: AnyObject, Sendable {
    func connect()
    func send<T: Codable & Sendable & Identifiable>(_ value: T) async
    func stream<T: Codable & Sendable & Identifiable>(as type: T.Type) async -> AsyncStream<ConnectionSnapshot<T>>
}
