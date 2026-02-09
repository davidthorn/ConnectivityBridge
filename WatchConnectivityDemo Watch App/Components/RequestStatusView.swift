//
//  RequestStatusView.swift
//  WatchConnectivityDemo Watch App
//

import SwiftUI

struct RequestStatusView: View {
    let pendingUntil: Date?
    let lastStatus: String?

    var body: some View {
        TimelineView(.periodic(from: Date(), by: 1)) { context in
            let statusText = statusText(now: context.date)
            if let statusText {
                HStack(spacing: 6) {
                    Image(systemName: pendingUntil == nil ? "checkmark.circle.fill" : "hourglass")
                    Text(statusText)
                }
                .font(.custom("Avenir Next", size: 10).weight(.semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.white.opacity(0.12))
                .clipShape(Capsule())
            }
        }
    }

    private func statusText(now: Date) -> String? {
        if let pendingUntil {
            let remaining = max(0, Int(pendingUntil.timeIntervalSince(now)))
            return "Waiting • \(remaining)s"
        }
        return lastStatus
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 8) {
            RequestStatusView(pendingUntil: Date().addingTimeInterval(8), lastStatus: nil)
            RequestStatusView(pendingUntil: nil, lastStatus: "Reply received")
        }
        .padding()
    }
}
