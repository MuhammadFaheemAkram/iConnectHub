//
//  FeedRepositoryTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
import Foundation
@testable import ConnectHub

/// Serialized: each test builds its own SwiftData store, and creating multiple
/// containers concurrently is not safe.
@MainActor
@Suite(.serialized)
struct FeedRepositoryTests {

    @Test func refreshInsertsPostsIntoCache() async throws {
        let service = StubFeedService(pages: [[.sample(id: "a"), .sample(id: "b")]])
        let repo = makeInMemoryFeedRepository(service: service)

        let result = try await repo.refresh(page: 0)

        #expect(result.posts.count == 2)
        #expect(result.fetchedCount == 2)
        #expect(Set(result.posts.map(\.id)) == ["a", "b"])
    }

    @Test func setLikedTogglesFlagAndCount() async throws {
        let service = StubFeedService(pages: [[.sample(id: "a", likeCount: 5)]])
        let repo = makeInMemoryFeedRepository(service: service)
        let initial = try await repo.refresh(page: 0)
        #expect(initial.posts.first?.isLiked == false)
        #expect(initial.posts.first?.likeCount == 5)

        try repo.setLiked(postId: "a", isLiked: true)
        var snapshot = try await repo.refresh(page: 0)
        #expect(snapshot.posts.first?.isLiked == true)
        #expect(snapshot.posts.first?.likeCount == 6)

        try repo.setLiked(postId: "a", isLiked: false)
        snapshot = try await repo.refresh(page: 0)
        #expect(snapshot.posts.first?.isLiked == false)
        #expect(snapshot.posts.first?.likeCount == 5)
    }

    @Test func setBookmarkedPersistsAcrossRefresh() async throws {
        let service = StubFeedService(pages: [[.sample(id: "a")]])
        let repo = makeInMemoryFeedRepository(service: service)
        _ = try await repo.refresh(page: 0)

        try repo.setBookmarked(postId: "a", isBookmarked: true)

        // A subsequent refresh must preserve local bookmark state.
        let snapshot = try await repo.refresh(page: 0)
        #expect(snapshot.posts.first?.isBookmarked == true)
    }

    @Test func refreshPreservesLikeStateOnExistingPost() async throws {
        let service = StubFeedService(pages: [[.sample(id: "a", likeCount: 10)]])
        let repo = makeInMemoryFeedRepository(service: service)
        _ = try await repo.refresh(page: 0)
        try repo.setLiked(postId: "a", isLiked: true)

        let snapshot = try await repo.refresh(page: 0)
        #expect(snapshot.posts.first?.isLiked == true)
        #expect(snapshot.posts.first?.likeCount == 11)
    }

    @Test func streamEmitsInitialThenRefreshThenMutation() async throws {
        let service = StubFeedService(pages: [[.sample(id: "a")]])
        let repo = makeInMemoryFeedRepository(service: service)
        let stream = repo.postsStream()

        let collector = Task { () -> [[Post]] in
            var received: [[Post]] = []
            for await posts in stream {
                received.append(posts)
                if received.count == 3 { break }
            }
            return received
        }

        _ = try await repo.refresh(page: 0)
        try repo.setBookmarked(postId: "a", isBookmarked: true)

        let received = await collector.value
        #expect(received.count == 3)
        #expect(received[0].isEmpty)                         // initial empty cache
        #expect(received[1].count == 1)                      // after refresh
        #expect(received[2].first?.isBookmarked == true)     // after bookmark
    }
}
