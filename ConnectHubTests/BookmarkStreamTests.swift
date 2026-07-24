//
//  BookmarkStreamTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
import Foundation
@testable import ConnectHub

/// Serialized: builds a SwiftData store per test.
@MainActor
@Suite(.serialized)
struct BookmarkStreamTests {

    @Test func bookmarksStreamReflectsBookmarkState() async throws {
        let repo = makeInMemoryFeedRepository(
            service: StubFeedService(pages: [[.sample(id: "a"), .sample(id: "b")]])
        )
        _ = try await repo.refresh(page: 0)

        #expect((await firstValue(repo.bookmarksStream()) ?? []).isEmpty)

        try repo.setBookmarked(postId: "a", isBookmarked: true)
        #expect((await firstValue(repo.bookmarksStream()) ?? []).map(\.id) == ["a"])

        try repo.setBookmarked(postId: "a", isBookmarked: false)
        #expect((await firstValue(repo.bookmarksStream()) ?? []).isEmpty)
    }

    @Test func bookmarksStreamEmitsOnChange() async throws {
        let repo = makeInMemoryFeedRepository(service: StubFeedService(pages: [[.sample(id: "a")]]))
        _ = try await repo.refresh(page: 0)
        let stream = repo.bookmarksStream()

        let collector = Task { () -> [[Post]] in
            var received: [[Post]] = []
            for await bookmarks in stream {
                received.append(bookmarks)
                if received.count == 2 { break }
            }
            return received
        }

        try repo.setBookmarked(postId: "a", isBookmarked: true)

        let received = await collector.value
        #expect(received.count == 2)
        #expect(received[0].isEmpty)                 // initial
        #expect(received[1].map(\.id) == ["a"])      // after bookmark
    }
}
