//
//  PostEntity.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation
import SwiftData

/// SwiftData persistence model for a cached post. Author fields are denormalized
/// (flattened) onto the post to keep the feed cache simple — a production app
/// might model `User` as its own `@Model` with a relationship instead.
///
/// `isLiked`/`isBookmarked`/`likeCount` are local user state and are preserved
/// across refreshes; the rest is refreshed from the API.
@Model
final class PostEntity {
    @Attribute(.unique) var id: String

    var authorId: String
    var authorName: String
    var authorAvatarURLString: String?
    var authorBio: String
    var authorFollowersCount: Int
    var authorFollowingCount: Int

    var content: String
    var imageURLString: String?
    var createdAt: Date
    var likeCount: Int
    var commentCount: Int
    var isLiked: Bool
    var isBookmarked: Bool

    init(
        id: String,
        authorId: String,
        authorName: String,
        authorAvatarURLString: String?,
        authorBio: String,
        authorFollowersCount: Int,
        authorFollowingCount: Int,
        content: String,
        imageURLString: String?,
        createdAt: Date,
        likeCount: Int,
        commentCount: Int,
        isLiked: Bool,
        isBookmarked: Bool
    ) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.authorAvatarURLString = authorAvatarURLString
        self.authorBio = authorBio
        self.authorFollowersCount = authorFollowersCount
        self.authorFollowingCount = authorFollowingCount
        self.content = content
        self.imageURLString = imageURLString
        self.createdAt = createdAt
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.isLiked = isLiked
        self.isBookmarked = isBookmarked
    }
}
