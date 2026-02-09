//
//  StatusPill.swift
//  WatchConnectivityDemo
//

import SwiftUI

struct StatusPill: View {
    let title: String
    let value: String
    let isOn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.custom("Avenir Next", size: 10).weight(.semibold))
                .foregroundColor(.white.opacity(0.55))
            HStack(spacing: 6) {
                Circle()
                    .fill(isOn ? Color(red: 0.35, green: 0.92, blue: 0.59) : Color(red: 0.95, green: 0.35, blue: 0.35))
                    .frame(width: 8, height: 8)
                Text(value)
                    .font(.custom("Avenir Next", size: 13).weight(.semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack {
            StatusPill(title: "Session", value: "Ready", isOn: true)
            StatusPill(title: "Reachable", value: "No", isOn: false)
        }
        .padding()
    }
}
