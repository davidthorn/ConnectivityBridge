//
//  RequestStatusView.swift
//  WatchConnectivityDemo
//

import SwiftUI

struct RequestStatusView: View {
    let pendingUntil: Date?
    let lastStatus: String?

    var body: some View {
        TimelineView(.periodic(from: Date(), by: 1)) { context in
            let statusText = statusText(now: context.date)
            if let statusText {
                HStack(spacing: 8) {
                    Image(systemName: pendingUntil == nil ? "checkmark.circle.fill" : "hourglass")
                    Text(statusText)
                }
                .font(.custom("Avenir Next", size: 12).weight(.semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.white.opacity(0.12))
                .clipShape(Capsule())
            }
        }
    }

    private func statusText(now: Date) -> String? {
        if let pendingUntil {
            let remaining = max(0, Int(pendingUntil.timeIntervalSince(now)))
            return "Waiting for reply • \(remaining)s"
        }
        return lastStatus
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 12) {
            RequestStatusView(pendingUntil: Date().addingTimeInterval(12), lastStatus: nil)
            RequestStatusView(pendingUntil: nil, lastStatus: "Reply received")
        }
        .padding()
    }
}
