//
//  SendMessageUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Sends a message and triggers the simulated reply.
@MainActor
struct SendMessageUseCase {
    let repository: ChatRepository
    func callAsFunction(conversationId: String, text: String) async {
        await repository.send(conversationId: conversationId, text: text)
    }
}
