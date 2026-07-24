//
//  AddCommentUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Adds a comment authored by the signed-in user and bumps the post's comment
/// count so the feed and detail screens stay consistent.
@MainActor
struct AddCommentUseCase {
    let commentRepository: CommentRepository
    let postRepository: PostRepository
    let sessionRepository: SessionRepository

    @discardableResult
    func callAsFunction(postId: String, text: String) async throws -> Comment {
        guard let author = sessionRepository.current?.asAuthor else {
            throw AppError.unauthorized
        }
        let comment = try await commentRepository.add(postId: postId, text: text, author: author)
        try? postRepository.adjustCommentCount(postId: postId, delta: 1)
        return comment
    }
}
