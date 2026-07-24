//
//  DefaultSearchRepository.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation
import SwiftData

/// Searches the cached posts (and their authors) locally, and persists recent
/// searches in `UserDefaults`. Search is offline — it never hits the network.
@MainActor
final class DefaultSearchRepository: SearchRepository {
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }
    private let defaults: UserDefaults
    private let recentsKey = "connecthub.recentSearches"
    private let maxRecents = 8
    private var continuations: [UUID: AsyncStream<[String]>.Continuation] = [:]

    init(container: ModelContainer, defaults: UserDefaults = .standard) {
        self.container = container
        self.defaults = defaults
    }

    func search(query: String) async -> SearchResults {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !needle.isEmpty else { return .empty }

        let descriptor = FetchDescriptor<PostEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let posts = ((try? context.fetch(descriptor)) ?? []).map(PostMapper.toDomain)

        let matchingPosts = posts.filter {
            $0.content.lowercased().contains(needle) || $0.author.name.lowercased().contains(needle)
        }

        // Unique authors (newest first) whose name matches.
        var seen = Set<String>()
        var users: [User] = []
        for author in posts.map(\.author) where author.name.lowercased().contains(needle) {
            if seen.insert(author.id).inserted { users.append(author) }
        }

        return SearchResults(users: users, posts: matchingPosts)
    }

    func recentSearchesStream() -> AsyncStream<[String]> {
        let (stream, continuation) = AsyncStream<[String]>.makeStream()
        let id = UUID()
        continuations[id] = continuation
        continuation.yield(loadRecents())
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor in self?.continuations[id] = nil }
        }
        return stream
    }

    func addRecentSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var recents = loadRecents()
        recents.removeAll { $0.caseInsensitiveCompare(trimmed) == .orderedSame }
        recents.insert(trimmed, at: 0)
        if recents.count > maxRecents { recents = Array(recents.prefix(maxRecents)) }
        defaults.set(recents, forKey: recentsKey)
        emit(recents)
    }

    func clearRecentSearches() {
        defaults.removeObject(forKey: recentsKey)
        emit([])
    }

    private func loadRecents() -> [String] {
        defaults.stringArray(forKey: recentsKey) ?? []
    }

    private func emit(_ recents: [String]) {
        for continuation in continuations.values { continuation.yield(recents) }
    }
}
