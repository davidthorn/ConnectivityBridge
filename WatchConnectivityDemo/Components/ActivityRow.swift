//
//  ActivityRow.swift
//  WatchConnectivityDemo
//

import SwiftUI

struct ActivityRow: View {
    let title: String
    let message: String
    let timestamp: Date?
    let iconName: String
    let iconColor: Color
    let isMatched: Bool
    let latencyText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: iconName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.custom("Avenir Next", size: 12).weight(.semibold))
                    .foregroundColor(.white.opacity(0.7))
                if isMatched {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(red: 0.42, green: 0.88, blue: 0.6))
                }
                Spacer()
                if let timestamp {
                    Text(Self.timeFormatter.string(from: timestamp))
                        .font(.custom("Avenir Next", size: 11))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            Text(message)
                .font(.custom("Avenir Next", size: 13))
                .foregroundColor(.white)
                .lineLimit(2)
            if let latencyText {
                Text(latencyText)
                    .font(.custom("Avenir Next", size: 11))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(12)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 12) {
            ActivityRow(
                title: "Request → #A1B2C3",
                message: "Hello from the phone app",
                timestamp: Date(),
                iconName: "iphone",
                iconColor: Color(red: 0.35, green: 0.78, blue: 0.98),
                isMatched: false,
                latencyText: nil
            )
            ActivityRow(
                title: "Reply ← #A1B2C3",
                message: "Hello back from watch",
                timestamp: Date().addingTimeInterval(-300),
                iconName: "applewatch",
                iconColor: Color(red: 0.98, green: 0.58, blue: 0.32),
                isMatched: true,
                latencyText: "Latency 0.42s"
            )
        }
        .padding()
    }
}
