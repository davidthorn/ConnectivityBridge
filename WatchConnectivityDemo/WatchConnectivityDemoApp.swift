//
//  WatchConnectivityDemoApp.swift
//  WatchConnectivityDemo
//
//  Created by David Thorn on 05.02.26.
//

import SwiftUI
import ConnectivityBridge

@main
struct WatchConnectivityDemoApp: App {
    @UIApplicationDelegateAdaptor(ConnectivityBridgeDelegate.self) var delegate
    let connection: WatchConnectivityBridge
    let typedBridge: TypedConnectivityBridge<BridgeMessage, BridgeMessage>
    
    init() {
        self.connection = WatchConnectivityBridge.shared
        self.typedBridge = TypedConnectivityBridge<BridgeMessage, BridgeMessage>(transport: connection)
    }
    
    var body: some Scene {
        WindowGroup {
            PhoneContentView(bridge: typedBridge)
        }
    }
}
