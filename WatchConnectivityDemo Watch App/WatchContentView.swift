//
//  WatchContentView.swift
//  WatchConnectivityDemo Watch App
//
//  Created by David Thorn on 05.02.26.
//

import SwiftUI
import ConnectivityBridge

struct WatchContentView: View {
    @StateObject private var viewModel: WatchViewModel

    init(bridge: TypedConnectivityBridge<BridgeMessage, BridgeMessage>) {
        _viewModel = StateObject(wrappedValue: WatchViewModel(bridge: bridge))
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.03, green: 0.05, blue: 0.08), Color(red: 0.01, green: 0.01, blue: 0.02)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        WatchHeaderView()
                        WatchStatusRow(
                            isConnected: viewModel.snapshot.connectable,
                            isReachable: viewModel.snapshot.isReachable,
                            isInstalled: viewModel.snapshot.isAppInstalled
                        )

                        RequestStatusView(
                            pendingUntil: viewModel.pendingUntil,
                            lastStatus: viewModel.lastStatus
                        )

                        FlowTile(
                            title: "Request",
                            subtitle: "Watch → iPhone",
                            icon: "paperplane.fill",
                            accent: Color(red: 0.35, green: 0.78, blue: 0.98),
                            message: viewModel.lastRequestText ?? "Tap to send request",
                            pulse: viewModel.sendPulse,
                            onTap: { await viewModel.sendPrimaryRequest() }
                        )

                        FlowTile(
                            title: "Reply",
                            subtitle: "iPhone → Watch",
                            icon: "arrowshape.turn.up.left.fill",
                            accent: Color(red: 0.98, green: 0.58, blue: 0.32),
                            message: viewModel.lastReplyText ?? "Waiting for reply",
                            pulse: viewModel.replyPulse,
                            onTap: { await viewModel.sendReplyRequest() }
                        )

                        QuickSendButton(
                            isEnabled: viewModel.snapshot.canSendMessage,
                            title: "Send Request",
                            disabledTitle: "Link Required",
                            onTap: { await viewModel.sendQuickRequest() }
                        )

                        WatchActivityPanel(logs: viewModel.logs, onClear: viewModel.clearLogs)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height)
                }
            }
        }
        .task { await viewModel.observe() }
    }
}

#Preview {
    WatchContentView(bridge: TypedConnectivityBridge(transport: WatchConnectivityBridge.shared))
}
