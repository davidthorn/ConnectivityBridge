//
//  PhoneContentView.swift
//  WatchConnectivityDemo
//
//  Created by David Thorn on 05.02.26.
//

import SwiftUI
import ConnectivityBridge

struct PhoneContentView: View {
    @StateObject private var viewModel: PhoneViewModel

    init(bridge: TypedConnectivityBridge<BridgeMessage, BridgeMessage>) {
        _viewModel = StateObject(wrappedValue: PhoneViewModel(bridge: bridge))
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.06, green: 0.10, blue: 0.14), Color(red: 0.02, green: 0.02, blue: 0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        PhoneHeaderView()

                        PhoneStatusStrip(
                            isConnected: viewModel.snapshot.connectable,
                            isReachable: viewModel.snapshot.isReachable,
                            isInstalled: viewModel.snapshot.isAppInstalled
                        )

                        RequestStatusView(
                            pendingUntil: viewModel.pendingUntil,
                            lastStatus: viewModel.lastStatus
                        )

                        PhoneFlowPanel(
                            requestText: viewModel.lastRequestText,
                            replyText: viewModel.lastReplyText,
                            canSendMessage: viewModel.snapshot.canSendMessage,
                            sendPulse: viewModel.sendPulse,
                            replyPulse: viewModel.replyPulse,
                            onSend: { Task { await viewModel.sendPrimaryRequest() } },
                            onReply: { Task { await viewModel.sendReplyRequest() } }
                        )

                        PhoneActivityPanel(logs: viewModel.logs, onClear: viewModel.clearLogs)

                        Spacer(minLength: 8)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height)
                }
            }
        }
        .task { await viewModel.observe() }
    }
}

#Preview {
    PhoneContentView(bridge: TypedConnectivityBridge(transport: WatchConnectivityBridge.shared))
}
