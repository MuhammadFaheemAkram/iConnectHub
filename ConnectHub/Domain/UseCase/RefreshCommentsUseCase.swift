//
//  RefreshCommentsUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Fetches a post's comments from the API into the cache.
@MainActor
struct RefreshCommentsUseCase {
    let repository: CommentRepository

    @discardableResult
    func callAsFunction(postId: String) async throws -> [Comment] {
        try await repository.refresh(postId: postId)
    }
}
