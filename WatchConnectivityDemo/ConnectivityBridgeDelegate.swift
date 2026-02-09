//
//  ConnectivityBridgeDelegate.swift
//  WatchConnectivityDemo
//
//  Created by David Thorn on 08.02.26.
//

import SwiftUI
import ConnectivityBridge

final class ConnectivityBridgeDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        WatchConnectivityBridge.shared.connect()
        return true
    }
}
