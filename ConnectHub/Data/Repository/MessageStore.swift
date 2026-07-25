//
//  MessageStore.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Thread-safe, actor-isolated store for chat messages.
///
/// The `actor` guarantees that concurrent sends and received replies mutate the
/// message lists one at a time, so the store never corrupts even under parallel
/// access. Values in and out are `Sendable` (`Message`), so results can be
/// handed to the main-actor UI safely.
actor MessageStore {
    private var messagesByConversation: [String: [Message]] = [:]

    /// Replaces a conversation's messages (used when seeding from the service).
    func setMessages(_ messages: [Message], for conversationId: String) {
        messagesByConversation[conversationId] = messages
    }

    /// Appends a message and returns the conversation's full, ordered list.
    func append(_ message: Message) -> [Message] {
        messagesByConversation[message.conversationId, default: []].append(message)
        return messagesByConversation[message.conversationId] ?? []
    }

    func messages(for conversationId: String) -> [Message] {
        messagesByConversation[conversationId] ?? []
    }

    func count(for conversationId: String) -> Int {
        messagesByConversation[conversationId]?.count ?? 0
    }
}
