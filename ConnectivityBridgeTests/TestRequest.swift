//
//  TestRequest.swift
//  WatchConnectivityDemo
//
//  Created by David Thorn on 09.02.26.
//

import Foundation

struct TestRequest: Codable, Sendable, Identifiable, Equatable {
    let id: UUID
    let text: String
}
