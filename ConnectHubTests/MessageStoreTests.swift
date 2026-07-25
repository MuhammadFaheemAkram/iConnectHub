//
//  MessageStoreTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
@testable import ConnectHub

@MainActor
struct MessageStoreTests {

    @Test func appendGrowsTheOrderedList() async {
        let store = MessageStore()
        _ = await store.append(.sample(id: "1", conversationId: "c"))
        let messages = await store.append(.sample(id: "2", conversationId: "c"))
        #expect(messages.count == 2)
        #expect(messages.map(\.id) == ["1", "2"])
    }

    @Test func messagesAreScopedByConversation() async {
        let store = MessageStore()
        _ = await store.append(.sample(id: "1", conversationId: "c1"))
        _ = await store.append(.sample(id: "2", conversationId: "c2"))
        #expect(await store.count(for: "c1") == 1)
        #expect(await store.count(for: "c2") == 1)
    }

    @Test func setMessagesReplacesTheConversation() async {
        let store = MessageStore()
        _ = await store.append(.sample(id: "1", conversationId: "c"))
        await store.setMessages(
            [.sample(id: "a", conversationId: "c"), .sample(id: "b", conversationId: "c")],
            for: "c"
        )
        #expect(await store.count(for: "c") == 2)
    }

    /// The actor must serialize concurrent appends so none are lost.
    @Test func concurrentAppendsStayConsistent() async {
        let store = MessageStore()
        await withTaskGroup(of: Void.self) { group in
            for index in 0..<200 {
                group.addTask {
                    _ = await store.append(.sample(id: "\(index)", conversationId: "c"))
                }
            }
        }
        #expect(await store.count(for: "c") == 200)
    }
}
