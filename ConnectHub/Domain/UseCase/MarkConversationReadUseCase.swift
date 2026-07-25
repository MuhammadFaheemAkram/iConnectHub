//
//  MarkConversationReadUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Clears a conversation's unread count.
@MainActor
struct MarkConversationReadUseCase {
    let repository: ChatRepository
    func callAsFunction(conversationId: String) { repository.markConversationRead(conversationId: conversationId) }
}
