//
//  CommentEntity.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation
import SwiftData

/// SwiftData persistence model for a cached comment. Author fields are
/// denormalized, matching `PostEntity`. `isOwnComment` marks comments the user
/// added, which are preserved across refreshes and can be deleted.
@Model
final class CommentEntity {
    @Attribute(.unique) var id: String
    var postId: String
    var authorId: String
    var authorName: String
    var authorAvatarURLString: String?
    var text: String
    var createdAt: Date
    var isOwnComment: Bool

    init(
        id: String,
        postId: String,
        authorId: String,
        authorName: String,
        authorAvatarURLString: String?,
        text: String,
        createdAt: Date,
        isOwnComment: Bool
    ) {
        self.id = id
        self.postId = postId
        self.authorId = authorId
        self.authorName = authorName
        self.authorAvatarURLString = authorAvatarURLString
        self.text = text
        self.createdAt = createdAt
        self.isOwnComment = isOwnComment
    }
}
