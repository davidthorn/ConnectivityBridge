# ConnectivityBridge Documentation

This document explains ConnectivityBridge from two perspectives:

- **Junior-friendly**: copy/paste sections to get a working connection.
- **Architect-friendly**: understand the roles, flow, and tradeoffs.

It covers two layers:

- `TypedConnectivityBridge<Request, Response>`: typed request/response with timeouts.
- `WatchConnectivityBridge`: low-level WatchConnectivity wrapper.

Both are built for Swift Concurrency and can be used independently.

---

## Quick Start (Copy/Paste)

### 1) Add the Package

In your app target, add the Swift Package and import it:

```swift
import ConnectivityBridge
```

### 2) Start the Bridge Early

**iOS (AppDelegate)**

```swift

import ConnectivityBridge

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        WatchConnectivityBridge.shared.connect()
        return true
    }
}

@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```

**watchOS (App init)**

```swift

import ConnectivityBridge

@main
struct YourWatchApp: App {
    let bridge = WatchConnectivityBridge.shared

    init() {
        bridge.connect()
    }

    var body: some Scene {
        WindowGroup { WatchContentView() }
    }
}
```

### 3) Send a Request + Await a Reply

```swift
let bridge = TypedConnectivityBridge<BridgeMessage, BridgeMessage>(
    transport: WatchConnectivityBridge.shared
)

let request = BridgeMessage(text: "Ping?", origin: "iPhone")
let reply = try await bridge.request(request, timeout: .seconds(2))
print("Reply: \(reply.text)")
```

### 4) Handle Incoming Requests

```swift
Task {
    let requests = await bridge.requests()
    for await req in requests {
        let response = BridgeMessage(text: "Pong", origin: "Watch", id: req.id)
        await bridge.reply(to: req.id, with: response)
    }
}
```

---

## What Each Layer Does (Architect View)

### TypedConnectivityBridge

**Purpose**: Provide a typed request/response API with timeouts and correlation IDs.

**How it works**:

1. A request payload is wrapped in an envelope with a UUID.
2. The envelope is encoded and sent via `WatchConnectivityBridge`.
3. Replies arrive as envelopes with the same UUID.
4. The bridge matches reply → request and resumes the awaiting call.

**When to use**:

- You want to `await` replies and handle timeouts.
- You want a clear request → reply model across phone/watch.

### WatchConnectivityBridge

**Purpose**: A thin, async wrapper around `WCSession` that exposes connection state and typed payloads.

**How it works**:

- Uses `WCSession` to send `Data`.
- Decodes received `Data` into typed payloads.
- Emits `ConnectionSnapshot<T>` with reachability and last sent/received payloads.

**When to use**:

- You want full control over send/receive.
- You don’t need typed request/response matching.

---

## TypedConnectivityBridge

### Type Requirements

Both request and response types must conform to:

- `Codable`
- `Sendable`
- `Identifiable`

This allows payloads to be encoded, sent over `WCSession`, and correlated by `id`.

### Basic Setup

```swift
let bridge = TypedConnectivityBridge<BridgeMessage, BridgeMessage>(
    transport: WatchConnectivityBridge.shared
)

bridge.connect()
```

### Send Without a Reply

Use `send(_:)` when you do not expect a reply. The call throws if encoding fails or `WCSession` reports an error.

```swift
let message = BridgeMessage(text: "One-way ping", origin: "iPhone")
try await bridge.send(message)
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

`send(_:)` can throw:

- `BridgeError.cannotSend` when the session is not ready.
- `BridgeError.encodingFailed` when the payload cannot be encoded.
- `BridgeError.sendFailed(String)` when `WCSession` reports a failure.

Handle it explicitly:

```swift
do {
    let reply = try await bridge.request(request, timeout: .seconds(2))
} catch let BridgeError.timeout(id) {
    print("Timeout for id: \(id)")
}
```

---

## WatchConnectivityBridge

### Connect

```swift
let transport = WatchConnectivityBridge.shared
transport.connect()
```

### Send a Typed Payload

```swift
let payload = BridgeMessage(text: "Hello", origin: "iPhone")
try await transport.send(payload)
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

---

## Simulator Setup (Quick)

- Launch the iOS app **and** the watchOS app in their simulators.
- Use **Xcode → Device and Simulators** to ensure the watch simulator is paired with your phone simulator.
- When paired, the UI shows **Connected / Reachable** and requests begin to succeed.

---

## Demo App

A full iOS + watchOS demo app ships with this repo so you can run the bridge on simulators or devices and see the request/reply flow, status changes, and latency in real time.

---

## Notes

- `TypedConnectivityBridge` is an `actor` and is safe to use from concurrent tasks.
- `WatchConnectivityBridge` uses `WCSession` under the hood and is designed to be shared (`.shared`).
