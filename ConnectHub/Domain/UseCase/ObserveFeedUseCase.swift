//
//  ObserveFeedUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Streams the cached feed for offline-first display.
@MainActor
struct ObserveFeedUseCase {
    let repository: FeedRepository

    func callAsFunction() -> AsyncStream<[Post]> {
        repository.postsStream()
    }
}
