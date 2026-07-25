//
//  ChatRepositoryTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
@testable import ConnectHub

@MainActor
struct ChatRepositoryTests {

    @Test func loadMessagesSeedsFromService() async throws {
        let service = StubChatService(messageDTOs: [
            "c1": [.sample(id: "m1", conversationId: "c1", isMine: false),
                   .sample(id: "m2", conversationId: "c1", isMine: true)]
        ])
        let repo = DefaultChatRepository(service: service)

        try await repo.loadMessages(conversationId: "c1")

        let messages = await firstValue(repo.messagesStream(conversationId: "c1")) ?? []
        #expect(messages.count == 2)
    }

    @Test func refreshLoadsConversations() async throws {
        let service = StubChatService(conversationDTOs: [.sample(id: "c1", unreadCount: 3)])
        let repo = DefaultChatRepository(service: service)

        try await repo.refreshConversations()

        let conversations = await firstValue(repo.conversationsStream()) ?? []
        #expect(conversations.count == 1)
        #expect(conversations.first?.unreadCount == 3)
    }

    @Test func markConversationReadClearsUnread() async throws {
        let service = StubChatService(conversationDTOs: [.sample(id: "c1", unreadCount: 3)])
        let repo = DefaultChatRepository(service: service)
        try await repo.refreshConversations()

        repo.markConversationRead(conversationId: "c1")

        let conversations = await firstValue(repo.conversationsStream()) ?? []
        #expect(conversations.first?.unreadCount == 0)
    }

    @Test func sendAppendsMineThenSimulatedReply() async throws {
        let service = StubChatService(conversationDTOs: [.sample(id: "c1")], replyText: "Reply!")
        let repo = DefaultChatRepository(service: service)
        try await repo.refreshConversations()

        let stream = repo.messagesStream(conversationId: "c1")
        let collector = Task { () -> [Message] in
            for await messages in stream where messages.count >= 2 { return messages }
            return []
        }

        await repo.send(conversationId: "c1", text: "Hello")

        let messages = await collector.value
        #expect(messages.count == 2)
        #expect(messages.first?.isMine == true)
        #expect(messages.last?.isMine == false)
        #expect(messages.last?.text == "Reply!")
    }

    @Test func typingIndicatorTurnsOnDuringReplyThenOff() async throws {
        let service = StubChatService(conversationDTOs: [.sample(id: "c1")])
        let repo = DefaultChatRepository(service: service)
        try await repo.refreshConversations()

        let typingStream = repo.typingStream(conversationId: "c1")
        let collector = Task { () -> [Bool] in
            var seen: [Bool] = []
            for await isTyping in typingStream {
                seen.append(isTyping)
                if seen.count >= 3 { return seen } // initial false, true, false
            }
            return seen
        }

        await repo.send(conversationId: "c1", text: "Hi")

        let seen = await collector.value
        #expect(seen.contains(true))
        #expect(seen.last == false)
    }
}
