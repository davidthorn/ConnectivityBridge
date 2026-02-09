//
//  StatusDot.swift
//  WatchConnectivityDemo Watch App
//

import SwiftUI

struct StatusDot: View {
    let title: String
    let isOn: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(isOn ? Color(red: 0.35, green: 0.92, blue: 0.59) : Color(red: 0.95, green: 0.35, blue: 0.35))
                .frame(width: 8, height: 8)
            Text(title)
                .font(.custom("Avenir Next", size: 9).weight(.semibold))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack {
            StatusDot(title: "Session", isOn: true)
            StatusDot(title: "Reach", isOn: false)
            StatusDot(title: "Phone", isOn: true)
        }
        .padding()
    }
}
