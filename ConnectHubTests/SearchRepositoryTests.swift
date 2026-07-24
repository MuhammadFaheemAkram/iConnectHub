//
//  SearchRepositoryTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
import Foundation
@testable import ConnectHub

/// Serialized: search reads a SwiftData store built per test.
@MainActor
@Suite(.serialized)
struct SearchRepositoryTests {

    private func makeSearchRepositoryWithPosts() async throws -> DefaultSearchRepository {
        let container = PersistenceController.makeContainer(inMemory: true)
        let feed = DefaultFeedRepository(
            service: StubFeedService(pages: [[.sample(id: "p1"), .sample(id: "p2")]]),
            container: container
        )
        _ = try await feed.refresh(page: 0)
        return DefaultSearchRepository(container: container, defaults: makeEphemeralDefaults())
    }

    @Test func searchMatchesPostContent() async throws {
        let search = try await makeSearchRepositoryWithPosts()
        let results = await search.search(query: "Content p1")
        #expect(results.posts.contains { $0.id == "p1" })
    }

    @Test func searchMatchesAuthorNameAsUser() async throws {
        let search = try await makeSearchRepositoryWithPosts()
        let results = await search.search(query: "ada")
        #expect(results.users.contains { $0.name == "Ada" })
    }

    @Test func blankQueryReturnsEmpty() async throws {
        let search = try await makeSearchRepositoryWithPosts()
        let results = await search.search(query: "   ")
        #expect(results.isEmpty)
    }

    @Test func recentSearchesAreDedupedNewestFirst() async {
        let search = DefaultSearchRepository(
            container: PersistenceController.makeContainer(inMemory: true),
            defaults: makeEphemeralDefaults()
        )
        search.addRecentSearch("swift")
        search.addRecentSearch("ios")
        search.addRecentSearch("Swift") // case-insensitive duplicate → moves to front

        let recents = await firstValue(search.recentSearchesStream()) ?? []
        #expect(recents == ["Swift", "ios"])
    }

    @Test func clearRecentSearchesEmptiesTheList() async {
        let search = DefaultSearchRepository(
            container: PersistenceController.makeContainer(inMemory: true),
            defaults: makeEphemeralDefaults()
        )
        search.addRecentSearch("swift")
        search.clearRecentSearches()

        let recents = await firstValue(search.recentSearchesStream()) ?? []
        #expect(recents.isEmpty)
    }
}
