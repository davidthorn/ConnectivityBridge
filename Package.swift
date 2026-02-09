// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ConnectivityBridge",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "ConnectivityBridge",
            targets: ["ConnectivityBridge"]
        )
    ],
    targets: [
        .target(
            name: "ConnectivityBridge",
            path: "./ConnectivityBridge"
        ),
        .testTarget(
            name: "ConnectivityBridgeTests",
            dependencies: ["ConnectivityBridge"],
            path: "./ConnectivityBridgeTests"
        )
    ]
)
