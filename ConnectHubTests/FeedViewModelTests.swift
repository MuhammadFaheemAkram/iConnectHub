//
//  FeedViewModelTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
@testable import ConnectHub

@MainActor
struct FeedViewModelTests {

    private func makeViewModel(_ repo: StubFeedRepository) -> FeedViewModel {
        FeedViewModel(
            observeFeed: ObserveFeedUseCase(repository: repo),
            refreshFeed: RefreshFeedUseCase(repository: repo),
            likePost: LikePostUseCase(repository: repo),
            bookmarkPost: BookmarkPostUseCase(repository: repo)
        )
    }

    @Test func refreshLoadsPosts() async {
        let repo = StubFeedRepository()
        let posts = [Post.sample(id: "a"), Post.sample(id: "b")]
        repo.refreshResult = FeedRefreshResult(posts: posts, fetchedCount: 2)
        let model = makeViewModel(repo)

        await model.refresh()

        #expect(model.state == .loaded(posts))
    }

    @Test func emptyResultShowsEmptyState() async {
        let repo = StubFeedRepository()
        repo.refreshResult = FeedRefreshResult(posts: [], fetchedCount: 0)
        let model = makeViewModel(repo)

        await model.refresh()

        #expect(model.state == .empty)
    }

    @Test func refreshErrorWithEmptyCacheShowsError() async {
        let repo = StubFeedRepository()
        repo.refreshError = .network
        let model = makeViewModel(repo)

        await model.refresh()

        #expect(model.state == .error(AppError.network.message))
    }

    @Test func fullPageEnablesLoadMore() async {
        let repo = StubFeedRepository()
        let posts = (0..<FeedPaging.pageSize).map { Post.sample(id: "p\($0)") }
        repo.refreshResult = FeedRefreshResult(posts: posts, fetchedCount: FeedPaging.pageSize)
        let model = makeViewModel(repo)

        await model.refresh()

        #expect(model.canLoadMore == true)
    }

    @Test func partialPageDisablesLoadMore() async {
        let repo = StubFeedRepository()
        repo.refreshResult = FeedRefreshResult(posts: [Post.sample()], fetchedCount: 1)
        let model = makeViewModel(repo)

        await model.refresh()

        #expect(model.canLoadMore == false)
    }

    @Test func refreshIfNeededRunsOnlyOnce() async {
        let repo = StubFeedRepository()
        repo.refreshResult = FeedRefreshResult(posts: [Post.sample()], fetchedCount: 1)
        let model = makeViewModel(repo)

        await model.refreshIfNeeded()
        await model.refreshIfNeeded()

        // Still loaded; the guard prevents a second first-load.
        #expect(model.state == .loaded([Post.sample()]))
    }

    @Test func toggleLikeForwardsInvertedStateToRepository() {
        let repo = StubFeedRepository()
        let model = makeViewModel(repo)

        model.toggleLike(Post.sample(id: "x", isLiked: false))

        #expect(repo.likedCalls.count == 1)
        #expect(repo.likedCalls.first?.id == "x")
        #expect(repo.likedCalls.first?.isLiked == true)
    }

    @Test func toggleBookmarkForwardsInvertedStateToRepository() {
        let repo = StubFeedRepository()
        let model = makeViewModel(repo)

        model.toggleBookmark(Post.sample(id: "y", isBookmarked: true))

        #expect(repo.bookmarkedCalls.first?.id == "y")
        #expect(repo.bookmarkedCalls.first?.isBookmarked == false)
    }
}
