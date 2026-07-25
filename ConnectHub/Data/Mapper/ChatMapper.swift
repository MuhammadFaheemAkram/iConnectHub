//
//  ChatMapper.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Maps chat DTOs into domain models.
enum ChatMapper {
    static func toDomain(_ dto: ConversationDTO) -> Conversation {
        Conversation(
            id: dto.id,
            participant: UserMapper.map(dto.participant),
            lastMessage: dto.lastMessage,
            unreadCount: dto.unreadCount,
            updatedAt: dto.updatedAt
        )
    }

    static func toDomain(_ dto: MessageDTO) -> Message {
        Message(
            id: dto.id,
            conversationId: dto.conversationId,
            senderId: dto.senderId,
            text: dto.text,
            createdAt: dto.createdAt,
            isMine: dto.isMine
        )
    }
}
