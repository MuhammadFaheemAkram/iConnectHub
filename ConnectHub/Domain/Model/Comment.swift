//
//  Comment.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Core domain model for a comment on a post. `isOwnComment` is local state:
/// true for comments the signed-in user added, which they may delete.
struct Comment: Identifiable, Sendable, Equatable {
    let id: String
    let postId: String
    let author: User
    var text: String
    let createdAt: Date
    let isOwnComment: Bool
}
