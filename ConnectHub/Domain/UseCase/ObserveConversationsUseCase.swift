//
//  ObserveConversationsUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Streams the conversation list.
@MainActor
struct ObserveConversationsUseCase {
    let repository: ChatRepository
    func callAsFunction() -> AsyncStream<[Conversation]> { repository.conversationsStream() }
}
