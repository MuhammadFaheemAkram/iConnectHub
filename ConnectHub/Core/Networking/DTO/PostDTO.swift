//
//  PostDTO.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Wire model for a feed post. `createdAt` is decoded from an ISO-8601 string.
/// The API is the source of truth for content and counts; like/bookmark state
/// is local and therefore absent here.
struct PostDTO: Codable, Equatable, Sendable {
    let id: String
    let author: UserDTO
    let content: String
    let imageURL: String?
    let createdAt: Date
    let likeCount: Int
    let commentCount: Int
}
