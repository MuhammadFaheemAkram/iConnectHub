//
//  CommentDTO.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Wire model for a comment. `createdAt` is decoded from an ISO-8601 string.
struct CommentDTO: Codable, Equatable, Sendable {
    let id: String
    let postId: String
    let author: UserDTO
    let text: String
    let createdAt: Date
}
