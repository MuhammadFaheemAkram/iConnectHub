//
//  ObserveBookmarksUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Streams the bookmarked posts from the offline cache.
@MainActor
struct ObserveBookmarksUseCase {
    let repository: BookmarkRepository

    func callAsFunction() -> AsyncStream<[Post]> {
        repository.bookmarksStream()
    }
}
