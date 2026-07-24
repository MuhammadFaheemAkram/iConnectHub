//
//  Phase5TestSupport.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation
import SwiftData
@testable import ConnectHub

// MARK: - Repository stubs

@MainActor
final class StubSearchRepository: SearchRepository {
    var searchResults: SearchResults = .empty
    var recents: [String] = []
    private(set) var addedRecents: [String] = []
    private(set) var clearCalled = false
    private var continuations: [UUID: AsyncStream<[String]>.Continuation] = [:]

    func search(query: String) async -> SearchResults { searchResults }

    func recentSearchesStream() -> AsyncStream<[String]> {
        let (stream, continuation) = AsyncStream<[String]>.makeStream()
        let id = UUID()
        continuations[id] = continuation
        continuation.yield(recents)
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor in self?.continuations[id] = nil }
        }
        return stream
    }

    func addRecentSearch(_ query: String) {
        addedRecents.append(query)
        recents.removeAll { $0 == query }
        recents.insert(query, at: 0)
        emit()
    }

    func clearRecentSearches() {
        clearCalled = true
        recents = []
        emit()
    }

    private func emit() {
        for continuation in continuations.values { continuation.yield(recents) }
    }
}

@MainActor
final class StubBookmarkRepository: BookmarkRepository {
    var bookmarks: [Post] = []
    private var continuations: [UUID: AsyncStream<[Post]>.Continuation] = [:]

    func bookmarksStream() -> AsyncStream<[Post]> {
        let (stream, continuation) = AsyncStream<[Post]>.makeStream()
        let id = UUID()
        continuations[id] = continuation
        continuation.yield(bookmarks)
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor in self?.continuations[id] = nil }
        }
        return stream
    }
}

@MainActor
final class StubProfileRepository: ProfileRepository {
    var profile: User = .sample()
    private(set) var updates: [(name: String, bio: String, avatarURL: URL?)] = []
    private var continuations: [UUID: AsyncStream<User>.Continuation] = [:]

    func currentProfile() -> User { profile }

    func observeProfile() -> AsyncStream<User> {
        let (stream, continuation) = AsyncStream<User>.makeStream()
        let id = UUID()
        continuations[id] = continuation
        continuation.yield(profile)
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor in self?.continuations[id] = nil }
        }
        return stream
    }

    func updateProfile(name: String, bio: String, avatarURL: URL?) {
        updates.append((name, bio, avatarURL))
        profile.name = name
        profile.bio = bio
        profile.avatarURL = avatarURL
        for continuation in continuations.values { continuation.yield(profile) }
    }
}

// MARK: - Helpers

@MainActor
func makeEphemeralDefaults() -> UserDefaults {
    let suite = "ConnectHubTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defaults.removePersistentDomain(forName: suite)
    return defaults
}
