//
//  ChatDTO.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Wire model for a conversation.
struct ConversationDTO: Codable, Equatable, Sendable {
    let id: String
    let participant: UserDTO
    let lastMessage: String
    let unreadCount: Int
    let updatedAt: Date
}

/// Wire model for a message. `isMine` is provided by the (fake) backend.
struct MessageDTO: Codable, Equatable, Sendable {
    let id: String
    let conversationId: String
    let senderId: String
    let text: String
    let createdAt: Date
    let isMine: Bool
}
