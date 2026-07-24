//
//  DeleteCommentUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Deletes one of the user's own comments and decrements the post's comment count.
@MainActor
struct DeleteCommentUseCase {
    let commentRepository: CommentRepository
    let postRepository: PostRepository

    func callAsFunction(commentId: String, postId: String) throws {
        try commentRepository.delete(commentId: commentId)
        try? postRepository.adjustCommentCount(postId: postId, delta: -1)
    }
}
