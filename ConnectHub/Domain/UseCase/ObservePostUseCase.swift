//
//  ObservePostUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Streams a single cached post so the detail screen stays in sync with likes,
/// bookmarks, and comment-count changes.
@MainActor
struct ObservePostUseCase {
    let repository: PostRepository

    func callAsFunction(id: String) -> AsyncStream<Post?> {
        repository.observePost(id: id)
    }
}
