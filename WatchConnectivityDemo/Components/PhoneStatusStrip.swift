//
//  PhoneStatusStrip.swift
//  WatchConnectivityDemo
//

import SwiftUI

struct PhoneStatusStrip: View {
    let isConnected: Bool
    let isReachable: Bool
    let isInstalled: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            StatusPill(
                title: "Session",
                value: isConnected ? "Ready" : "Waiting",
                isOn: isConnected
            )
            StatusPill(
                title: "Reachable",
                value: isReachable ? "Yes" : "No",
                isOn: isReachable
            )
            StatusPill(
                title: "Watch",
                value: isInstalled ? "Installed" : "Missing",
                isOn: isInstalled
            )
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        PhoneStatusStrip(isConnected: true, isReachable: false, isInstalled: true)
            .padding()
    }
}
