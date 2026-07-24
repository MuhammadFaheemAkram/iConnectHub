//
//  BookmarkRepository.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Offline-first bookmarks boundary. Streams the bookmarked posts from the same
/// SwiftData store the feed uses, so bookmarking anywhere updates this list.
/// Removing a bookmark is `BookmarkPostUseCase(isBookmarked: false)`.
@MainActor
protocol BookmarkRepository {
    func bookmarksStream() -> AsyncStream<[Post]>
}
