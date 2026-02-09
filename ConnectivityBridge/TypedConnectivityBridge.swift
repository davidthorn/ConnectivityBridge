//
//  TypedConnectivityBridge.swift
//  WatchConnectivityDemo
//

import Foundation

public actor TypedConnectivityBridge<Request: Codable & Sendable & Identifiable, Response: Codable & Sendable & Identifiable>: TypedConnectivityBridging {
    public struct RequestContext: Sendable {
        public let id: UUID
        public let payload: Request
        public init(id: UUID, payload: Request) {
            self.id = id
            self.payload = payload
        }
    }
    
    private let transport: WatchConnectivityBridging
    private let pending = PendingResponses<Response>()
    private let requestsStream = RequestsStream<RequestContext>()
    private let eventsStream = EventsStream<TypedBridgeEvent<Request, Response>>(maxBuffer: 200)
    private var lastStatus: ConnectionStatus?
    private var handledReplyIds: Set<UUID> = []
    private var handledRequestIds: Set<UUID> = []
    private var requestTask: Task<Void, Never>?
    private var responseTask: Task<Void, Never>?
    
    public init(transport: WatchConnectivityBridging) {
        self.transport = transport
        Task { await startListening() }
    }
    
    deinit {
        requestTask?.cancel()
        responseTask?.cancel()
    }

    public func shutdown() {
        requestTask?.cancel()
        responseTask?.cancel()
    }
    
    public func connect() {
        transport.connect()
    }
    
    public func requests() async -> AsyncStream<RequestContext> {
        await requestsStream.stream()
    }

    public func events() async -> AsyncStream<TypedBridgeEvent<Request, Response>> {
        await eventsStream.stream()
    }

    public func stream() async -> AsyncStream<ConnectionSnapshot<Request>> {
        let envelopeStream = await transport.stream(as: Envelope<Request>.self)
        return AsyncStream { continuation in
            let task = Task {
                for await snapshot in envelopeStream {
                    if Task.isCancelled { break }
                    let status = ConnectionStatus(
                        connectable: snapshot.connectable,
                        isReachable: snapshot.isReachable,
                        isAppInstalled: snapshot.isAppInstalled,
                        canSendMessage: snapshot.canSendMessage
                    )
                    if status != lastStatus {
                        lastStatus = status
                        await eventsStream.yield(.statusChanged(status, date: Date()))
                    }
                    let mapped = ConnectionSnapshot<Request>(
                        connectable: snapshot.connectable,
                        isReachable: snapshot.isReachable,
                        isAppInstalled: snapshot.isAppInstalled,
                        canSendMessage: snapshot.canSendMessage,
                        received: snapshot.received?.payload,
                        sent: snapshot.sent?.payload
                    )
                    continuation.yield(mapped)
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    public func request(_ payload: Request, timeout: Duration) async throws -> Response {
        let id = UUID()
        let envelope = Envelope(id: id, kind: .request, payload: payload)
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                let timeoutTask = Task {
                    // The timeout task is cancelled when a reply arrives. In that case
                    // Task.sleep throws CancellationError; we ignore it and exit early.
                    try? await Task.sleep(for: timeout)
                    // If we were cancelled by our own resolve/timeout cleanup, stop here.
                    if Task.isCancelled { return }
                    // If we reach here, the sleep completed normally, so this represents a real timeout.
                    if await pending.isPending(id: id) {
                        await eventsStream.yield(.timeout(id: id, date: Date()))
                        await pending.timeout(id: id)
                    }
                }
                await pending.store(id: id, continuation: continuation, timeoutTask: timeoutTask)
                do {
                    try await transport.send(envelope)
                    await eventsStream.yield(.sentRequest(payload, id: id, date: Date()))
                } catch {
                    await pending.fail(id: id, error: error)
                }
            }
        }
    }
    
    public func send(_ payload: Request) async throws {
        let id = UUID()
        let envelope = Envelope(id: id, kind: .request, payload: payload)
        try await transport.send(envelope)
        await eventsStream.yield(.sentRequest(payload, id: id, date: Date()))
    }

    public func reply(to id: UUID, with response: Response) async {
        let reply = Envelope(id: id, kind: .reply, payload: response)
        try? await transport.send(reply)
        await eventsStream.yield(.sentReply(response, id: id, date: Date()))
    }
    
    private func startListening() async {
        responseTask = Task {
            let stream = await transport.stream(as: Envelope<Response>.self)
            for await snapshot in stream {
                if Task.isCancelled { break }
                guard let message = snapshot.received, message.kind == .reply else { continue }
                if handledReplyIds.contains(message.id) { continue }
                handledReplyIds.insert(message.id)
                await eventsStream.yield(.receivedReply(message.payload, id: message.id, date: Date()))
                await pending.resolve(id: message.id, value: message.payload)
            }
        }
        
        requestTask = Task {
            let stream = await transport.stream(as: Envelope<Request>.self)
            for await snapshot in stream {
                if Task.isCancelled { break }
                guard let message = snapshot.received, message.kind == .request else { continue }
                if handledRequestIds.contains(message.id) { continue }
                handledRequestIds.insert(message.id)
                await eventsStream.yield(.receivedRequest(message.payload, id: message.id, date: Date()))
                let context = RequestContext(id: message.id, payload: message.payload)
                await requestsStream.yield(context)
            }
        }
    }
}
