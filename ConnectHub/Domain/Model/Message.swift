//
//  Message.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// A single chat message. `Sendable` so the actor-backed message store can hand
/// it to the (main-actor) UI safely. `isMine` drives bubble alignment.
struct Message: Identifiable, Sendable, Equatable {
    let id: String
    let conversationId: String
    let senderId: String
    var text: String
    let createdAt: Date
    let isMine: Bool
}
