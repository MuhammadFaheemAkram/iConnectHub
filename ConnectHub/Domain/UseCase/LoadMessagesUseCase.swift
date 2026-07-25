//
//  LoadMessagesUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Loads a conversation's messages from the API into the message store.
@MainActor
struct LoadMessagesUseCase {
    let repository: ChatRepository
    func callAsFunction(conversationId: String) async throws {
        try await repository.loadMessages(conversationId: conversationId)
    }
}
