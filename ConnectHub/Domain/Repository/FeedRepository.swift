//
//  FeedRepository.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Result of refreshing a feed page: the full cached feed after the upsert
/// (what the UI shows) plus how many posts the fetched page returned (used to
/// decide whether more pages exist).
struct FeedRefreshResult: Sendable, Equatable {
    let posts: [Post]
    let fetchedCount: Int
}

/// Offline-first feed boundary. The UI observes `postsStream()` (backed by
/// SwiftData); `refresh(page:)` pulls from the API into the cache; like/bookmark
/// mutate the cache. `@MainActor` because it wraps the main SwiftData context.
@MainActor
protocol FeedRepository {
    /// Emits the cached posts immediately, then again on every change.
    func postsStream() -> AsyncStream<[Post]>
    /// Fetches a page from the API, upserts it into the cache, and returns the
    /// full cached feed plus the fetched page size.
    @discardableResult
    func refresh(page: Int) async throws -> FeedRefreshResult
    func setLiked(postId: String, isLiked: Bool) throws
    func setBookmarked(postId: String, isBookmarked: Bool) throws
    /// Deletes all cached posts and comments (Settings → Clear Cache).
    func clearCache() throws
}
