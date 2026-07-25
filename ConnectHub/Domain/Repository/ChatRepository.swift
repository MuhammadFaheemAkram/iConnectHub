//
//  ChatRepository.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Chat boundary. Conversations and messages are observed via `AsyncStream`s;
/// `typingStream` drives the typing indicator while a simulated reply is being
/// generated. Backed by an actor-isolated message store.
@MainActor
protocol ChatRepository {
    func conversationsStream() -> AsyncStream<[Conversation]>
    func refreshConversations() async throws
    func markConversationRead(conversationId: String)

    func messagesStream(conversationId: String) -> AsyncStream<[Message]>
    func typingStream(conversationId: String) -> AsyncStream<Bool>
    func loadMessages(conversationId: String) async throws
    /// Sends the user's message and triggers a delayed simulated reply.
    func send(conversationId: String, text: String) async
}
