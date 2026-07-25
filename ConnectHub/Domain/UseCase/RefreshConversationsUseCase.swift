//
//  RefreshConversationsUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Loads conversations from the API.
@MainActor
struct RefreshConversationsUseCase {
    let repository: ChatRepository
    func callAsFunction() async throws { try await repository.refreshConversations() }
}
