//
//  ChatService.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Service boundary for chat. `simulatedReply` returns a delayed fake response
/// so the chat feels alive without a backend.
protocol ChatService: Sendable {
    func conversations() async throws -> [ConversationDTO]
    func messages(conversationId: String) async throws -> [MessageDTO]
    func sendMessage(conversationId: String, text: String) async throws -> MessageDTO
    func simulatedReply(to text: String) async throws -> MessageDTO
}
