//
//  WatchConnectivityDemoApp.swift
//  WatchConnectivityDemo Watch App
//
//  Created by David Thorn on 05.02.26.
//

import SwiftUI
import ConnectivityBridge

@main
struct WatchConnectivityDemo_Watch_App: App {
    let myConnection: WatchConnectivityBridge
    let typedBridge: TypedConnectivityBridge<BridgeMessage, BridgeMessage>
    init() {
        let connection = WatchConnectivityBridge.shared
        let bridge = TypedConnectivityBridge<BridgeMessage, BridgeMessage>(transport: connection)
        self.myConnection = connection
        self.typedBridge = bridge
        connection.connect()
    }
    
    var body: some Scene {
        WindowGroup {
            WatchContentView(bridge: typedBridge)
        }
    }
}
