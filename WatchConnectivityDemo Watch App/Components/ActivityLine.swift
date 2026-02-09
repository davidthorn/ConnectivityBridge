//
//  ActivityLine.swift
//  WatchConnectivityDemo Watch App
//

import SwiftUI

struct ActivityLine: View {
    let label: String
    let message: String
    let timestamp: Date?
    let iconName: String
    let iconColor: Color
    let isMatched: Bool
    let latencyText: String?

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: iconName)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(iconColor)
            Text(label)
                .font(.custom("Avenir Next", size: 10).weight(.semibold))
                .foregroundColor(.white.opacity(0.65))
                .frame(width: 60, alignment: .leading)
            if isMatched {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(Color(red: 0.42, green: 0.88, blue: 0.6))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(message)
                    .font(.custom("Avenir Next", size: 10))
                    .foregroundColor(.white)
                    .lineLimit(2)
                if let latencyText {
                    Text(latencyText)
                        .font(.custom("Avenir Next", size: 9))
                        .foregroundColor(.white.opacity(0.55))
                }
                if let timestamp {
                    Text(Self.timeFormatter.string(from: timestamp))
                        .font(.custom("Avenir Next", size: 9))
                        .foregroundColor(.white.opacity(0.45))
                }
            }
        }
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
        VStack(alignment: .leading, spacing: 8) {
            ActivityLine(
                label: "Req → #A1B2C3",
                message: "Hello from watch",
                timestamp: Date(),
                iconName: "applewatch",
                iconColor: Color(red: 0.35, green: 0.78, blue: 0.98),
                isMatched: false,
                latencyText: nil
            )
            ActivityLine(
                label: "Rep ← #A1B2C3",
                message: "Hello back from phone",
                timestamp: Date().addingTimeInterval(-120),
                iconName: "iphone",
                iconColor: Color(red: 0.98, green: 0.58, blue: 0.32),
                isMatched: true,
                latencyText: "0.42s"
            )
        }
        .padding()
    }
}
