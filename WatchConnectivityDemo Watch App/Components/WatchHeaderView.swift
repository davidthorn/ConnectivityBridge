//
//  WatchHeaderView.swift
//  WatchConnectivityDemo Watch App
//

import SwiftUI

struct WatchHeaderView: View {
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Watch Connectivity")
                    .font(.custom("Avenir Next", size: 16).weight(.semibold))
                    .foregroundColor(.white)
                Text("Demo")
                    .font(.custom("Avenir Next", size: 10).weight(.semibold))
                    .foregroundColor(.white)
                Text("Watch Link")
                    .font(.custom("Avenir Next", size: 11))
                    .foregroundColor(.white.opacity(0.65))
            }
            Spacer()
            Text("Watch")
                .font(.custom("Avenir Next", size: 10).weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.white.opacity(0.12))
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        WatchHeaderView()
            .padding()
    }
}
