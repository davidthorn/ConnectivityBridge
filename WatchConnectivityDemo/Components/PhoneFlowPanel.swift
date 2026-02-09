//
//  PhoneFlowPanel.swift
//  WatchConnectivityDemo
//

import SwiftUI

struct PhoneFlowPanel: View {
    let requestText: String?
    let replyText: String?
    let canSendMessage: Bool
    let sendPulse: Bool
    let replyPulse: Bool
    let onSend: () -> Void
    let onReply: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Request + Reply")
                    .font(.custom("Avenir Next", size: 16).weight(.semibold))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "dot.radiowaves.left.and.right")
                    .foregroundColor(.white.opacity(0.7))
            }

            HStack(spacing: 12) {
                FlowCard(
                    title: "Request",
                    subtitle: "iPhone → Watch",
                    icon: "paperplane.fill",
                    accent: Color(red: 0.35, green: 0.78, blue: 0.98),
                    message: requestText ?? "Tap to send request",
                    pulse: sendPulse,
                    onTap: onSend
                )

                FlowCard(
                    title: "Reply",
                    subtitle: "Watch → iPhone",
                    icon: "arrowshape.turn.up.left.fill",
                    accent: Color(red: 0.98, green: 0.58, blue: 0.32),
                    message: replyText ?? "Waiting for reply",
                    pulse: replyPulse,
                    onTap: onReply
                )
            }

            Button {
                onSend()
            } label: {
                HStack {
                    Image(systemName: "bolt.horizontal.fill")
                    Text(canSendMessage ? "Send Request" : "Simulator Not Linked")
                }
                .font(.custom("Avenir Next", size: 16).weight(.semibold))
                .foregroundColor(.black)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(canSendMessage ? Color(red: 0.98, green: 0.86, blue: 0.44) : Color.white.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .disabled(!canSendMessage)
        }
        .padding(18)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [Color.black, Color(red: 0.08, green: 0.1, blue: 0.12)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        PhoneFlowPanel(
            requestText: "Hello from phone",
            replyText: "Reply from watch",
            canSendMessage: true,
            sendPulse: true,
            replyPulse: false,
            onSend: {},
            onReply: {}
        )
        .padding()
    }
}
