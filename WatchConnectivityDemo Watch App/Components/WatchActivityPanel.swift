//
//  WatchActivityPanel.swift
//  WatchConnectivityDemo Watch App
//

import SwiftUI

struct WatchActivityPanel: View {
    let logs: [CommLogItem]
    let onClear: () -> Void
    @StateObject private var viewModel: WatchActivityPanelViewModel

    init(logs: [CommLogItem], onClear: @escaping () -> Void) {
        self.logs = logs
        self.onClear = onClear
        _viewModel = StateObject(wrappedValue: WatchActivityPanelViewModel(logs: logs))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Latest")
                    .font(.custom("Avenir Next", size: 12).weight(.semibold))
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Button("Clear") {
                    onClear()
                }
                .font(.custom("Avenir Next", size: 10).weight(.semibold))
                .foregroundColor(.white.opacity(0.6))
            }

            if logs.isEmpty {
                Text("No messages yet")
                    .font(.custom("Avenir Next", size: 10))
                    .foregroundColor(.white.opacity(0.6))
            } else {
                VStack(spacing: 6) {
                    ForEach(viewModel.sortedLogs) { item in
                        ActivityLine(
                            label: label(for: item),
                            message: item.message,
                            timestamp: item.timestamp,
                            iconName: iconName(for: item),
                            iconColor: iconColor(for: item),
                            isMatched: item.isMatched,
                            latencyText: viewModel.latencyText(for: item)
                        )
                    }
                }
            }
        }
        .padding(10)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .onChange(of: logs) { _, newLogs in
            viewModel.update(logs: newLogs)
        }
    }


    private func label(for item: CommLogItem) -> String {
        let arrow = item.direction == .sent ? "→" : "←"
        let kind: String
        switch item.kind {
        case .request:
            kind = "Req"
        case .reply:
            kind = "Rep"
        case .system:
            kind = "Sys"
        }
        return "\(kind) \(arrow) #\(item.idShort)"
    }

    private func iconName(for item: CommLogItem) -> String {
        if item.kind == .system { return "dot.radiowaves.left.and.right" }
        return item.direction == .sent ? "applewatch" : "iphone"
    }

    private func iconColor(for item: CommLogItem) -> Color {
        if item.kind == .system {
            return Color(red: 0.56, green: 0.82, blue: 0.98)
        }
        return item.direction == .sent
            ? Color(red: 0.35, green: 0.78, blue: 0.98)
            : Color(red: 0.98, green: 0.58, blue: 0.32)
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [Color.black, Color(red: 0.08, green: 0.1, blue: 0.12)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        WatchActivityPanel(
            logs: [
                CommLogItem(direction: .sent, kind: .request, message: "Ping", messageId: UUID()),
                CommLogItem(direction: .received, kind: .reply, message: "Pong", messageId: UUID(), isMatched: true),
                CommLogItem(direction: .received, kind: .system, message: "Connected • Reachable • App installed • Can send", messageId: UUID())
            ],
            onClear: {}
        )
        .padding()
    }
}
