//
//  QuickSendButton.swift
//  WatchConnectivityDemo Watch App
//

import SwiftUI

struct QuickSendButton: View {
    let isEnabled: Bool
    let title: String
    let disabledTitle: String
    let onTap: () async -> Void

    var body: some View {
        Button {
            Task { await onTap() }
        } label: {
            HStack {
                Image(systemName: "bolt.horizontal.fill")
                Text(isEnabled ? title : disabledTitle)
            }
            .font(.custom("Avenir Next", size: 14).weight(.semibold))
            .foregroundColor(.black)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(isEnabled ? Color(red: 0.98, green: 0.86, blue: 0.44) : Color.white.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [Color.black, Color(red: 0.08, green: 0.1, blue: 0.12)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        VStack(spacing: 12) {
            QuickSendButton(
                isEnabled: true,
                title: "Send Request",
                disabledTitle: "Link Required",
                onTap: {}
            )
            QuickSendButton(
                isEnabled: false,
                title: "Send Request",
                disabledTitle: "Link Required",
                onTap: {}
            )
        }
        .padding()
    }
}
