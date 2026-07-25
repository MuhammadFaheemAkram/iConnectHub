//
//  ChatDetailViewModel.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Drives a single chat: observes the actor-backed messages and the typing
/// indicator, loads history, and sends messages (which trigger a simulated
/// reply). The title is resolved from the conversation list.
@MainActor
@Observable
final class ChatDetailViewModel {
    let conversationId: String
    private(set) var title = "Chat"
    private(set) var messages: [Message] = []
    private(set) var isTyping = false
    private(set) var isLoading = true
    var input = ""

    private let observeMessages: ObserveMessagesUseCase
    private let observeTyping: ObserveTypingUseCase
    private let observeConversations: ObserveConversationsUseCase
    private let loadMessages: LoadMessagesUseCase
    private let sendMessage: SendMessageUseCase
    private let markRead: MarkConversationReadUseCase

    init(
        conversationId: String,
        observeMessages: ObserveMessagesUseCase,
        observeTyping: ObserveTypingUseCase,
        observeConversations: ObserveConversationsUseCase,
        loadMessages: LoadMessagesUseCase,
        sendMessage: SendMessageUseCase,
        markRead: MarkConversationReadUseCase
    ) {
        self.conversationId = conversationId
        self.observeMessages = observeMessages
        self.observeTyping = observeTyping
        self.observeConversations = observeConversations
        self.loadMessages = loadMessages
        self.sendMessage = sendMessage
        self.markRead = markRead
    }

    func observeMessagesStream() async {
        for await messages in observeMessages(conversationId: conversationId) {
            self.messages = messages
        }
    }

    func observeTypingStream() async {
        for await typing in observeTyping(conversationId: conversationId) {
            isTyping = typing
        }
    }

    func observeTitle() async {
        for await conversations in observeConversations() {
            if let match = conversations.first(where: { $0.id == conversationId }) {
                title = match.participant.name
            }
        }
    }

    func load() async {
        markRead(conversationId: conversationId)
        try? await loadMessages(conversationId: conversationId)
        isLoading = false
    }

    var canSend: Bool {
        !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func send() async {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        input = ""
        await sendMessage(conversationId: conversationId, text: text)
    }
}
