//
//  ConnectivityBridgeTests.swift
//  ConnectivityBridgeTests
//
//  Created by David Thorn on 08.02.26.
//

import Foundation
import Testing
@testable import ConnectivityBridge

struct ConnectivityBridgeTests {
    @Test func requestResponseSucceeds() async throws {
        let phoneTransport = MockTransport()
        let watchTransport = MockTransport()
        await phoneTransport.setPeer(watchTransport)
        await watchTransport.setPeer(phoneTransport)

        let phoneBridge = TypedConnectivityBridge<TestRequest, TestResponse>(transport: phoneTransport)
        let watchBridge = TypedConnectivityBridge<TestRequest, TestResponse>(transport: watchTransport)
        defer {
            Task {
                await phoneBridge.shutdown()
                await watchBridge.shutdown()
            }
        }

        let responder = Task {
            let requests = await watchBridge.requests()
            for await req in requests {
                let response = TestResponse(id: req.id, text: "Pong")
                await watchBridge.reply(to: req.id, with: response)
                break
            }
        }
        defer { responder.cancel() }

        let request = TestRequest(id: UUID(), text: "Ping")
        let reply = try await phoneBridge.request(request, timeout: .milliseconds(500))
        #expect(reply.text == "Pong")
    }

    @Test func requestTimesOut() async {
        let phoneTransport = MockTransport()
        let watchTransport = MockTransport()
        await phoneTransport.setPeer(watchTransport)
        await watchTransport.setPeer(phoneTransport)

        let phoneBridge = TypedConnectivityBridge<TestRequest, TestResponse>(transport: phoneTransport)
        defer { Task { await phoneBridge.shutdown() } }

        let request = TestRequest(id: UUID(), text: "Ping")
        await #expect(throws: BridgeError.self) {
            _ = try await phoneBridge.request(request, timeout: .milliseconds(150))
        }
    }

    @Test func sendDeliversRequest() async throws {
        let phoneTransport = MockTransport()
        let watchTransport = MockTransport()
        await phoneTransport.setPeer(watchTransport)
        await watchTransport.setPeer(phoneTransport)

        let phoneBridge = TypedConnectivityBridge<TestRequest, TestResponse>(transport: phoneTransport)
        let watchBridge = TypedConnectivityBridge<TestRequest, TestResponse>(transport: watchTransport)
        defer {
            Task {
                await phoneBridge.shutdown()
                await watchBridge.shutdown()
            }
        }

        let receiver = Task<TestRequest, Never> {
            let requests = await watchBridge.requests()
            for await req in requests {
                return req.payload
            }
            return TestRequest(id: UUID(), text: "unexpected")
        }
        defer { receiver.cancel() }

        let request = TestRequest(id: UUID(), text: "One-way")
        await phoneBridge.send(request)
        let received = try await withTimeout(.milliseconds(500)) { await receiver.value }
        #expect(received == request)
    }

    @Test func concurrentRequestsMatchResponses() async throws {
        let phoneTransport = MockTransport()
        let watchTransport = MockTransport()
        await phoneTransport.setPeer(watchTransport)
        await watchTransport.setPeer(phoneTransport)

        let phoneBridge = TypedConnectivityBridge<TestRequest, TestResponse>(transport: phoneTransport)
        let watchBridge = TypedConnectivityBridge<TestRequest, TestResponse>(transport: watchTransport)
        defer {
            Task {
                await phoneBridge.shutdown()
                await watchBridge.shutdown()
            }
        }

        let responder = Task {
            let requests = await watchBridge.requests()
            for await req in requests {
                let response = TestResponse(id: req.id, text: "Reply-\(req.payload.text)")
                await watchBridge.reply(to: req.id, with: response)
            }
        }
        defer { responder.cancel() }

        let requests = (1...5).map { TestRequest(id: UUID(), text: "\($0)") }
        let replies = try await withThrowingTaskGroup(of: TestResponse.self) { group in
            for req in requests {
                group.addTask { try await phoneBridge.request(req, timeout: .seconds(1)) }
            }
            var out: [TestResponse] = []
            while let value = try await group.next() {
                out.append(value)
            }
            return out
        }

        let replyTexts = Set(replies.map { $0.text })
        let expected = Set(requests.map { "Reply-\($0.text)" })
        #expect(replyTexts == expected)
    }

    @Test func lateReplyAfterTimeoutIsIgnored() async throws {
        let phoneTransport = MockTransport()
        let watchTransport = MockTransport()
        await phoneTransport.setPeer(watchTransport)
        await watchTransport.setPeer(phoneTransport)

        let phoneBridge = TypedConnectivityBridge<TestRequest, TestResponse>(transport: phoneTransport)
        let watchBridge = TypedConnectivityBridge<TestRequest, TestResponse>(transport: watchTransport)
        defer {
            Task {
                await phoneBridge.shutdown()
                await watchBridge.shutdown()
            }
        }

        let requests = await watchBridge.requests()
        let watcher = Task<TestRequest, Never> {
            for await req in requests {
                return req.payload
            }
            return TestRequest(id: UUID(), text: "unexpected")
        }

        let request = TestRequest(id: UUID(), text: "Ping")
        await #expect(throws: BridgeError.self) {
            _ = try await phoneBridge.request(request, timeout: .milliseconds(100))
        }

        let received = try await withTimeout(.milliseconds(500)) { await watcher.value }
        let lateReply = TestResponse(id: received.id, text: "Late")
        await watchBridge.reply(to: received.id, with: lateReply)
    }

    @Test func requestBufferedBeforeListener() async throws {
        let phoneTransport = MockTransport()
        let watchTransport = MockTransport()
        await phoneTransport.setPeer(watchTransport)
        await watchTransport.setPeer(phoneTransport)

        let phoneBridge = TypedConnectivityBridge<TestRequest, TestResponse>(transport: phoneTransport)
        let watchBridge = TypedConnectivityBridge<TestRequest, TestResponse>(transport: watchTransport)
        defer {
            Task {
                await phoneBridge.shutdown()
                await watchBridge.shutdown()
            }
        }

        let request = TestRequest(id: UUID(), text: "Buffered")
        await phoneBridge.send(request)

        let receiver = Task<TestRequest, Never> {
            let requests = await watchBridge.requests()
            for await req in requests {
                return req.payload
            }
            return TestRequest(id: UUID(), text: "unexpected")
        }
        defer { receiver.cancel() }

        let received = try await withTimeout(.milliseconds(500)) { await receiver.value }
        #expect(received == request)
    }

    @Test func requestTaskCancelsCleanly() async throws {
        let phoneTransport = MockTransport()
        let watchTransport = MockTransport()
        await phoneTransport.setPeer(watchTransport)
        await watchTransport.setPeer(phoneTransport)

        let phoneBridge = TypedConnectivityBridge<TestRequest, TestResponse>(transport: phoneTransport)
        let watchBridge = TypedConnectivityBridge<TestRequest, TestResponse>(transport: watchTransport)
        defer {
            Task {
                await phoneBridge.shutdown()
                await watchBridge.shutdown()
            }
        }

        let requestsTask = Task {
            let requests = await watchBridge.requests()
            for await _ in requests {
                if Task.isCancelled { break }
            }
        }

        let requestTask = Task {
            let request = TestRequest(id: UUID(), text: "CancelMe")
            _ = try? await phoneBridge.request(request, timeout: .seconds(2))
        }

        requestsTask.cancel()
        requestTask.cancel()

        await Task.yield()
        #expect(requestsTask.isCancelled)
        #expect(requestTask.isCancelled)
    }
}
