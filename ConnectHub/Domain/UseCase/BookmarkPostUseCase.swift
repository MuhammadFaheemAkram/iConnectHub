//
//  BookmarkPostUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Sets the bookmark state of a post in the cache.
@MainActor
struct BookmarkPostUseCase {
    let repository: FeedRepository

    func callAsFunction(postId: String, isBookmarked: Bool) throws {
        try repository.setBookmarked(postId: postId, isBookmarked: isBookmarked)
    }
}
