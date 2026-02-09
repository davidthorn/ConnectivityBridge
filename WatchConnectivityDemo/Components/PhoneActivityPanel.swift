//
//  PhoneActivityPanel.swift
//  WatchConnectivityDemo
//

import SwiftUI

struct PhoneActivityPanel: View {
    let logs: [CommLogItem]
    let onClear: () -> Void
    @StateObject private var viewModel: PhoneActivityPanelViewModel

    init(logs: [CommLogItem], onClear: @escaping () -> Void) {
        self.logs = logs
        self.onClear = onClear
        _viewModel = StateObject(wrappedValue: PhoneActivityPanelViewModel(logs: logs))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Latest Activity")
                    .font(.custom("Avenir Next", size: 16).weight(.semibold))
                    .foregroundColor(.white)
                Spacer()
                Button("Clear") {
                    onClear()
                }
                .font(.custom("Avenir Next", size: 12).weight(.semibold))
                .foregroundColor(.white.opacity(0.7))
            }

            if logs.isEmpty {
                Text("No messages yet")
                    .font(.custom("Avenir Next", size: 13))
                    .foregroundColor(.white.opacity(0.7))
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.sortedLogs) { item in
                        ActivityRow(
                            title: title(for: item),
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
        .padding(18)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
        .onChange(of: logs) { _, newLogs in
            viewModel.update(logs: newLogs)
        }
    }

    private func title(for item: CommLogItem) -> String {
        let arrow = item.direction == .sent ? "→" : "←"
        let kind: String
        switch item.kind {
        case .request:
            kind = "Request"
        case .reply:
            kind = "Reply"
        case .system:
            kind = "System"
        }
        return "\(kind) \(arrow) #\(item.idShort)"
    }

    private func iconName(for item: CommLogItem) -> String {
        if item.kind == .system { return "dot.radiowaves.left.and.right" }
        return item.direction == .sent ? "iphone" : "applewatch"
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
        PhoneActivityPanel(
            logs: [
                CommLogItem(direction: .sent, kind: .request, message: "Hello from phone", messageId: UUID()),
                CommLogItem(direction: .received, kind: .reply, message: "Reply from watch", messageId: UUID(), isMatched: true),
                CommLogItem(direction: .received, kind: .system, message: "Connected • Reachable • App installed • Can send", messageId: UUID())
            ],
            onClear: {}
        )
        .padding()
    }
}
