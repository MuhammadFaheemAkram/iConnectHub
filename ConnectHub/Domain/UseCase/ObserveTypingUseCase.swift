//
//  ObserveTypingUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Streams the typing indicator for a conversation.
@MainActor
struct ObserveTypingUseCase {
    let repository: ChatRepository
    func callAsFunction(conversationId: String) -> AsyncStream<Bool> {
        repository.typingStream(conversationId: conversationId)
    }
}
