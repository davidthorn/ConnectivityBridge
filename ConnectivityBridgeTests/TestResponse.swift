//
//  TestResponse.swift
//  WatchConnectivityDemo
//
//  Created by David Thorn on 09.02.26.
//

import Foundation

struct TestResponse: Codable, Sendable, Identifiable, Equatable {
    let id: UUID
    let text: String
}
