//
//  Post.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Core domain model for a feed post. A plain, `Sendable` value type; the
/// author is the domain `User`. `isLiked`/`isBookmarked` are local user state
/// held in the SwiftData cache, not returned by the (fake) API.
struct Post: Identifiable, Sendable, Equatable {
    let id: String
    let author: User
    var content: String
    var imageURL: URL?
    let createdAt: Date
    var likeCount: Int
    var commentCount: Int
    var isLiked: Bool
    var isBookmarked: Bool
}
