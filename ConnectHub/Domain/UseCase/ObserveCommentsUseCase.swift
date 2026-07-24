//
//  ObserveCommentsUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Streams the cached comments for a post.
@MainActor
struct ObserveCommentsUseCase {
    let repository: CommentRepository

    func callAsFunction(postId: String) -> AsyncStream<[Comment]> {
        repository.observeComments(postId: postId)
    }
}
