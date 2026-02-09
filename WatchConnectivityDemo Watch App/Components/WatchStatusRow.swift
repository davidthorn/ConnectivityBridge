//
//  WatchStatusRow.swift
//  WatchConnectivityDemo Watch App
//

import SwiftUI

struct WatchStatusRow: View {
    let isConnected: Bool
    let isReachable: Bool
    let isInstalled: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            StatusDot(title: "Session", isOn: isConnected)
            StatusDot(title: "Reach", isOn: isReachable)
            StatusDot(title: "Phone", isOn: isInstalled)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        WatchStatusRow(isConnected: true, isReachable: false, isInstalled: true)
            .padding()
    }
}
