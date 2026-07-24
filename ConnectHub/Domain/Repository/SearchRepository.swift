//
//  SearchRepository.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Local search over the cached posts (and their authors), plus persisted recent
/// searches. `@MainActor` because it reads the main SwiftData context.
@MainActor
protocol SearchRepository {
    func search(query: String) async -> SearchResults
    /// Emits the recent searches immediately, then on every change.
    func recentSearchesStream() -> AsyncStream<[String]>
    func addRecentSearch(_ query: String)
    func clearRecentSearches()
}
