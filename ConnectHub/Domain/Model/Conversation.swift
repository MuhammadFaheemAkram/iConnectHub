//
//  Conversation.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// A chat conversation with one other participant. `Sendable` so it can cross
/// the actor boundary that backs the message store.
struct Conversation: Identifiable, Sendable, Equatable {
    let id: String
    let participant: User
    var lastMessage: String
    var unreadCount: Int
    var updatedAt: Date
}
