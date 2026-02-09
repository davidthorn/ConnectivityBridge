//
//  CommLogItem.swift
//  WatchConnectivityDemo Watch App
//

import Foundation

struct CommLogItem: Identifiable, Equatable {
    enum Direction {
        case sent
        case received
    }

    enum Kind {
        case request
        case reply
        case system
    }

    let id: UUID
    let messageId: UUID
    let direction: Direction
    let kind: Kind
    let message: String
    let timestamp: Date
    let isMatched: Bool

    var idShort: String {
        String(messageId.uuidString.prefix(6))
    }

    init(
        direction: Direction,
        kind: Kind,
        message: String,
        timestamp: Date = Date(),
        messageId: UUID,
        isMatched: Bool = false,
        id: UUID = UUID()
    ) {
        self.id = id
        self.messageId = messageId
        self.direction = direction
        self.kind = kind
        self.message = message
        self.timestamp = timestamp
        self.isMatched = isMatched
    }
}
