//
//  RefreshFeedUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Fetches a page from the API into the offline cache.
@MainActor
struct RefreshFeedUseCase {
    let repository: FeedRepository

    @discardableResult
    func callAsFunction(page: Int) async throws -> FeedRefreshResult {
        try await repository.refresh(page: page)
    }
}
