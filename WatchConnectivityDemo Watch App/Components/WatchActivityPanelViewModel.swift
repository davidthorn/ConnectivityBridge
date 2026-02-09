//
//  WatchActivityPanelViewModel.swift
//  WatchConnectivityDemo Watch App
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class WatchActivityPanelViewModel: ObservableObject {
    @Published private(set) var sortedLogs: [CommLogItem]
    private var latencyMap: [UUID: TimeInterval] = [:]

    init(logs: [CommLogItem]) {
        self.sortedLogs = logs.sorted { $0.timestamp > $1.timestamp }
        rebuildLatencyMap(from: logs)
    }

    func update(logs: [CommLogItem]) {
        sortedLogs = logs.sorted { $0.timestamp > $1.timestamp }
        rebuildLatencyMap(from: logs)
    }

    func latencyText(for item: CommLogItem) -> String? {
        guard item.kind == .reply, let latency = latencyMap[item.messageId] else { return nil }
        return String(format: "%.2fs", latency)
    }

    private func rebuildLatencyMap(from logs: [CommLogItem]) {
        var requestTimes: [UUID: Date] = [:]
        var replyTimes: [UUID: Date] = [:]
        for item in logs {
            switch item.kind {
            case .request:
                requestTimes[item.messageId] = item.timestamp
            case .reply:
                replyTimes[item.messageId] = item.timestamp
            case .system:
                continue
            }
        }
        var result: [UUID: TimeInterval] = [:]
        for (id, requestTime) in requestTimes {
            if let replyTime = replyTimes[id] {
                let delta = replyTime.timeIntervalSince(requestTime)
                if delta >= 0 {
                    result[id] = delta
                }
            }
        }
        latencyMap = result
    }
}
