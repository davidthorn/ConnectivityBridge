//
//  PhoneHeaderView.swift
//  WatchConnectivityDemo
//

import SwiftUI

struct PhoneHeaderView: View {
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Watch Connectivity")
                    .font(.custom("Avenir Next", size: 28).weight(.semibold))
                    .foregroundColor(.white)
                Text("Demo")
                    .font(.custom("Avenir Next", size: 18).weight(.semibold))
                    .foregroundColor(.white)
                Text("Phone ↔ Watch Live Link")
                    .font(.custom("Avenir Next", size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            Text("iPhone")
                .font(.custom("Avenir Next", size: 13).weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.white.opacity(0.12))
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        PhoneHeaderView()
            .padding()
    }
}
