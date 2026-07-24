//
//  CreatePostUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Creates a post authored by the signed-in user and inserts it into the cache,
/// so it appears at the top of the feed immediately.
@MainActor
struct CreatePostUseCase {
    let postRepository: PostRepository
    let sessionRepository: SessionRepository

    @discardableResult
    func callAsFunction(content: String, imageURL: URL?) async throws -> Post {
        guard let author = sessionRepository.current?.asAuthor else {
            throw AppError.unauthorized
        }
        return try await postRepository.createPost(content: content, imageURL: imageURL, author: author)
    }
}
