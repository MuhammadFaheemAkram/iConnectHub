//
//  DefaultChatRepository.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Default chat repository. The main-actor repository coordinates the streams
/// and the reply flow; the actual message state lives in the `MessageStore`
/// actor, which serializes concurrent sends and received replies.
@MainActor
final class DefaultChatRepository: ChatRepository {
    private let service: ChatService
    private let store = MessageStore()

    private var conversations: [Conversation] = []
    private var conversationContinuations: [UUID: AsyncStream<[Conversation]>.Continuation] = [:]
    private var messageContinuations: [String: [UUID: AsyncStream<[Message]>.Continuation]] = [:]
    private var typingContinuations: [String: [UUID: AsyncStream<Bool>.Continuation]] = [:]

    init(service: ChatService) {
        self.service = service
    }

    // MARK: - Conversations

    func conversationsStream() -> AsyncStream<[Conversation]> {
        let (stream, continuation) = AsyncStream<[Conversation]>.makeStream()
        let id = UUID()
        conversationContinuations[id] = continuation
        continuation.yield(conversations)
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor in self?.conversationContinuations[id] = nil }
        }
        return stream
    }

    func refreshConversations() async throws {
        let dtos = try await service.conversations()
        conversations = dtos.map(ChatMapper.toDomain)
        emitConversations()
    }

    func markConversationRead(conversationId: String) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else { return }
        conversations[index].unreadCount = 0
        emitConversations()
    }

    // MARK: - Messages

    func messagesStream(conversationId: String) -> AsyncStream<[Message]> {
        let (stream, continuation) = AsyncStream<[Message]>.makeStream()
        let id = UUID()
        messageContinuations[conversationId, default: [:]][id] = continuation
        Task { continuation.yield(await store.messages(for: conversationId)) }
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor in self?.messageContinuations[conversationId]?[id] = nil }
        }
        return stream
    }

    func typingStream(conversationId: String) -> AsyncStream<Bool> {
        let (stream, continuation) = AsyncStream<Bool>.makeStream()
        let id = UUID()
        typingContinuations[conversationId, default: [:]][id] = continuation
        continuation.yield(false)
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor in self?.typingContinuations[conversationId]?[id] = nil }
        }
        return stream
    }

    func loadMessages(conversationId: String) async throws {
        let dtos = try await service.messages(conversationId: conversationId)
        let messages = dtos.map(ChatMapper.toDomain)
        await store.setMessages(messages, for: conversationId)
        emitMessages(conversationId, messages)
    }

    func send(conversationId: String, text: String) async {
        let mine = Message(
            id: "m_\(UUID().uuidString.prefix(8))",
            conversationId: conversationId,
            senderId: "me",
            text: text,
            createdAt: Date(),
            isMine: true
        )
        let messages = await store.append(mine)
        emitMessages(conversationId, messages)
        updateLastMessage(conversationId, text)

        // Generate the reply in the background so `send` returns promptly.
        Task { await self.generateReply(conversationId: conversationId, to: text) }
    }

    private func generateReply(conversationId: String, to text: String) async {
        emitTyping(conversationId, true)
        defer { emitTyping(conversationId, false) }

        guard let reply = try? await service.simulatedReply(to: text) else { return }
        let participantId = conversations.first { $0.id == conversationId }?.participant.id ?? "them"
        let replyMessage = Message(
            id: reply.id,
            conversationId: conversationId,
            senderId: participantId,
            text: reply.text,
            createdAt: Date(),
            isMine: false
        )
        let messages = await store.append(replyMessage)
        emitMessages(conversationId, messages)
        updateLastMessage(conversationId, reply.text)
    }

    // MARK: - Emission

    private func emitConversations() {
        for continuation in conversationContinuations.values { continuation.yield(conversations) }
    }

    private func emitMessages(_ conversationId: String, _ messages: [Message]) {
        guard let continuations = messageContinuations[conversationId] else { return }
        for continuation in continuations.values { continuation.yield(messages) }
    }

    private func emitTyping(_ conversationId: String, _ isTyping: Bool) {
        guard let continuations = typingContinuations[conversationId] else { return }
        for continuation in continuations.values { continuation.yield(isTyping) }
    }

    private func updateLastMessage(_ conversationId: String, _ text: String) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else { return }
        conversations[index].lastMessage = text
        conversations[index].updatedAt = Date()
        conversations.sort { $0.updatedAt > $1.updatedAt }
        emitConversations()
    }
}
