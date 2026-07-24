//
//  LikePostUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Sets the like state of a post in the cache.
@MainActor
struct LikePostUseCase {
    let repository: FeedRepository

    func callAsFunction(postId: String, isLiked: Bool) throws {
        try repository.setLiked(postId: postId, isLiked: isLiked)
    }
}
