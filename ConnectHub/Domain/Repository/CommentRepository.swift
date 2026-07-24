//
//  CommentRepository.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Offline-first comments boundary for a post. Observes the cache; refresh pulls
/// from the API; add/delete mutate local state (own comments are preserved
/// across refreshes).
@MainActor
protocol CommentRepository {
    func observeComments(postId: String) -> AsyncStream<[Comment]>
    /// Fetches server comments into the cache and returns the full cached list.
    @discardableResult
    func refresh(postId: String) async throws -> [Comment]
    /// Adds an own comment and returns it.
    func add(postId: String, text: String, author: User) async throws -> Comment
    func delete(commentId: String) throws
}
