//
//  ObserveMessagesUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Streams a conversation's messages.
@MainActor
struct ObserveMessagesUseCase {
    let repository: ChatRepository
    func callAsFunction(conversationId: String) -> AsyncStream<[Message]> {
        repository.messagesStream(conversationId: conversationId)
    }
}
