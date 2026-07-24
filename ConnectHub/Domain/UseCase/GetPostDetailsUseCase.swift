//
//  GetPostDetailsUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Refreshes a single post's details from the API into the cache.
@MainActor
struct GetPostDetailsUseCase {
    let repository: PostRepository

    func callAsFunction(id: String) async throws {
        try await repository.refreshDetails(id: id)
    }
}
