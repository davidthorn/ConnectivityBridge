# ConnectivityBridge Documentation

This document describes the two layers provided by ConnectivityBridge:

- `TypedConnectivityBridge<Request, Response>`: a typed request/response bridge with timeouts.
- `WatchConnectivityBridge`: a low-level transport wrapper around `WCSession`.

Both are designed for Swift Concurrency and can be used independently.

## TypedConnectivityBridge

### What It Solves

`TypedConnectivityBridge` lets you send strongly-typed requests and receive strongly-typed replies. It correlates replies with requests using a shared `UUID` and provides a timeout mechanism so you can safely await responses.

### Type Requirements

Both request and response types must conform to:

- `Codable`
- `Sendable`
- `Identifiable`

This allows payloads to be encoded, sent over `WCSession`, and correlated by `id`.

### Basic Usage

```swift
let bridge = TypedConnectivityBridge<BridgeMessage, BridgeMessage>(
    transport: WatchConnectivityBridge.shared
)

bridge.connect()
```

### Send Without a Reply

Use `send(_:)` when you do not expect a reply.

```swift
let message = BridgeMessage(text: "One-way ping", origin: "iPhone")
await bridge.send(message)
```

### Send With a Reply + Timeout

Use `request(_:timeout:)` when you expect a reply. If the timeout expires, the call throws `BridgeError.timeout`.

```swift
let request = BridgeMessage(text: "Ping?", origin: "iPhone")
let reply = try await bridge.request(request, timeout: .seconds(2))
print(reply.text)
```

### Handle Incoming Requests

Incoming requests arrive as a stream of `RequestContext`. The `id` in the context must be used when replying.

```swift
Task {
    let requests = await bridge.requests()
    for await req in requests {
        let response = BridgeMessage(text: "Pong", origin: "Watch", id: req.id)
        await bridge.reply(to: req.id, with: response)
    }
}
```

### Observe Events

`events()` exposes a stream of bridge-level events (send, receive, timeout, status changes). This is useful for logs or diagnostics.

```swift
Task {
    let events = await bridge.events()
    for await event in events {
        print(event)
    }
}
```

### Connection Status Events

The bridge emits `.statusChanged` events when connectivity flags change:

- `connectable`
- `isReachable`
- `isAppInstalled`
- `canSendMessage`

### Error Handling

`request(_:timeout:)` can throw:

- `BridgeError.timeout(UUID)` when a reply is not received within the timeout.

Handle it explicitly:

```swift
do {
    let reply = try await bridge.request(request, timeout: .seconds(2))
} catch let BridgeError.timeout(id) {
    print("Timeout for id: \(id)")
}
```

## WatchConnectivityBridge

### What It Solves

`WatchConnectivityBridge` is a light wrapper around `WCSession` that provides a typed snapshot stream (`ConnectionSnapshot<T>`) and async `send`.

### Connect

```swift
let transport = WatchConnectivityBridge.shared
transport.connect()
```

### Send a Typed Payload

```swift
let payload = BridgeMessage(text: "Hello", origin: "iPhone")
await transport.send(payload)
```

### Stream Typed Messages

```swift
Task {
    let stream = await transport.stream(as: BridgeMessage.self)
    for await snapshot in stream {
        if let received = snapshot.received {
            print("Received: \(received.text)")
        }
    }
}
```

### Snapshot Fields

`ConnectionSnapshot<T>` contains:

- `connectable`
- `isReachable`
- `isAppInstalled`
- `canSendMessage`
- `received` (last received payload)
- `sent` (last sent payload)

## Demo App

A full iOS + watchOS demo app ships with this repo so you can run the bridge on simulators or devices and see the request/reply flow, status changes, and latency in real time.

## Best Practice: Starting The Bridge Early

To ensure WatchConnectivity is activated as early as possible, start the bridge at app launch. The recommended pattern differs slightly between iOS and watchOS:

### iOS (AppDelegate)

Initialize `WatchConnectivityBridge.shared` and call `connect()` in your `UIApplicationDelegate`. This starts the session before SwiftUI views appear.

```swift
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let bridge = WatchConnectivityBridge.shared
        bridge.connect()
        return true
    }
}

@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### watchOS (App Init)

On watchOS, initialize and connect in the `App` initializer.

```swift
@main
struct YourWatchApp: App {
    let bridge = WatchConnectivityBridge.shared

    init() {
        bridge.connect()
    }

    var body: some Scene {
        WindowGroup {
            WatchContentView()
        }
    }
}
```

## Notes

- `TypedConnectivityBridge` is an `actor` and is safe to use from concurrent tasks.
- `WatchConnectivityBridge` uses `WCSession` under the hood and is designed to be shared (`.shared`).
