//
//  FlowTile.swift
//  WatchConnectivityDemo Watch App
//

import SwiftUI

struct FlowTile: View {
    let title: String
    let subtitle: String
    let icon: String
    let accent: Color
    let message: String
    let pulse: Bool
    let onTap: () async -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(accent)
                Spacer()
            }
            Text(title)
                .font(.custom("Avenir Next", size: 12).weight(.semibold))
                .foregroundColor(.white)
            Text(subtitle)
                .font(.custom("Avenir Next", size: 10))
                .foregroundColor(.white.opacity(0.6))
            Text(message)
                .font(.custom("Avenir Next", size: 11))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(2)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(accent.opacity(pulse ? 0.9 : 0.35), lineWidth: pulse ? 2 : 1)
        )
        .shadow(color: accent.opacity(pulse ? 0.45 : 0.0), radius: pulse ? 8 : 0, x: 0, y: 0)
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .onTapGesture {
            Task { await onTap() }
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [Color.black, Color(red: 0.08, green: 0.1, blue: 0.12)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        VStack(spacing: 12) {
            FlowTile(
                title: "Send",
                subtitle: "Watch → iPhone",
                icon: "paperplane.fill",
                accent: Color(red: 0.35, green: 0.78, blue: 0.98),
                message: "Tap to transmit",
                pulse: true,
                onTap: {}
            )
            FlowTile(
                title: "Reply",
                subtitle: "iPhone → Watch",
                icon: "arrowshape.turn.up.left.fill",
                accent: Color(red: 0.98, green: 0.58, blue: 0.32),
                message: "Waiting for reply",
                pulse: false,
                onTap: {}
            )
        }
        .padding()
    }
}
