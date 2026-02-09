//
//  FlowCard.swift
//  WatchConnectivityDemo
//

import SwiftUI

struct FlowCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let accent: Color
    let message: String
    let pulse: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(accent)
                Spacer()
            }
            Text(title)
                .font(.custom("Avenir Next", size: 14).weight(.semibold))
                .foregroundColor(.white)
            Text(subtitle)
                .font(.custom("Avenir Next", size: 11))
                .foregroundColor(.white.opacity(0.6))
            Text(message)
                .font(.custom("Avenir Next", size: 12))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(accent.opacity(pulse ? 0.9 : 0.35), lineWidth: pulse ? 2 : 1)
        )
        .shadow(color: accent.opacity(pulse ? 0.45 : 0.0), radius: pulse ? 10 : 0, x: 0, y: 0)
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [Color.black, Color(red: 0.08, green: 0.1, blue: 0.12)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        HStack(spacing: 12) {
            FlowCard(
                title: "Send",
                subtitle: "iPhone → Watch",
                icon: "paperplane.fill",
                accent: Color(red: 0.35, green: 0.78, blue: 0.98),
                message: "Tap to transmit a ping",
                pulse: true,
                onTap: {}
            )
            FlowCard(
                title: "Reply",
                subtitle: "Watch → iPhone",
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
