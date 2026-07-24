//
//  PostRepository.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Single-post operations over the shared offline cache: observe one post,
/// refresh its details, create a new post, and adjust its comment count.
/// Backed by the same SwiftData store as the feed, so changes stay in sync.
@MainActor
protocol PostRepository {
    /// Emits the cached post immediately, then again on every change (or `nil`
    /// if it isn't cached).
    func observePost(id: String) -> AsyncStream<Post?>
    func refreshDetails(id: String) async throws
    /// Inserts a new post authored locally and returns it.
    @discardableResult
    func createPost(content: String, imageURL: URL?, author: User) async throws -> Post
    func adjustCommentCount(postId: String, delta: Int) throws
}
