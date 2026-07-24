//
//  FakeFeedServiceTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
@testable import ConnectHub

/// Exercises the fake feed service and its bundled JSON (the test host is the
/// app bundle, so the resource loads).
@MainActor
struct FakeFeedServiceTests {

    @Test func firstPageIsFullAndSortedNewestFirst() async throws {
        let service = FakeFeedService()

        let page = try await service.feed(page: 0)

        #expect(page.count == FeedPaging.pageSize)
        let dates = page.map(\.createdAt)
        #expect(dates == dates.sorted(by: >))
    }

    @Test func pagingReturnsEveryPostThenStops() async throws {
        let service = FakeFeedService()
        var all: [PostDTO] = []
        var page = 0
        while page < 20 {
            let batch = try await service.feed(page: page)
            if batch.isEmpty { break }
            all.append(contentsOf: batch)
            page += 1
        }

        #expect(all.count == 15)
        #expect(Set(all.map(\.id)).count == 15) // no duplicates across pages
    }

    @Test func postDetailsReturnsRequestedPost() async throws {
        let service = FakeFeedService()

        let post = try await service.postDetails(id: "p1")

        #expect(post.id == "p1")
    }

    @Test func postDetailsThrowsForUnknownID() async {
        let service = FakeFeedService()

        await #expect(throws: AppError.notFound) {
            try await service.postDetails(id: "does-not-exist")
        }
    }
}
