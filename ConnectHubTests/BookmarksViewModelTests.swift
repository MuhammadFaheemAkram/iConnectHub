//
//  BookmarksViewModelTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
@testable import ConnectHub

@MainActor
struct BookmarksViewModelTests {

    private func makeViewModel(feedRepo: StubFeedRepository) -> BookmarksViewModel {
        BookmarksViewModel(
            observeBookmarks: ObserveBookmarksUseCase(repository: StubBookmarkRepository()),
            bookmarkPost: BookmarkPostUseCase(repository: feedRepo),
            likePost: LikePostUseCase(repository: feedRepo)
        )
    }

    @Test func removeBookmarkForwardsFalse() {
        let feedRepo = StubFeedRepository()
        let model = makeViewModel(feedRepo: feedRepo)

        model.removeBookmark(.sample(id: "p1", isBookmarked: true))

        #expect(feedRepo.bookmarkedCalls.count == 1)
        #expect(feedRepo.bookmarkedCalls.first?.id == "p1")
        #expect(feedRepo.bookmarkedCalls.first?.isBookmarked == false)
    }

    @Test func toggleLikeForwardsInvertedState() {
        let feedRepo = StubFeedRepository()
        let model = makeViewModel(feedRepo: feedRepo)

        model.toggleLike(.sample(id: "p1", isLiked: false))

        #expect(feedRepo.likedCalls.first?.id == "p1")
        #expect(feedRepo.likedCalls.first?.isLiked == true)
    }
}
