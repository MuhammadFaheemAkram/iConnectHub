//
//  FeedViewModel.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Drives the Feed screen. Observes the offline cache for live updates and
/// refreshes pages from the API; exposes an explicit `FeedState` plus paging
/// flags. `refresh`/`loadMore` update state deterministically from the returned
/// cache snapshot, while `observe()` keeps the list live for like/bookmark and
/// cross-screen changes.
@MainActor
@Observable
final class FeedViewModel {
    private(set) var state: FeedState = .loading
    private(set) var isLoadingMore = false
    private(set) var canLoadMore = false

    private var posts: [Post] = []
    private var currentPage = 0
    private var didFirstLoad = false
    private var hasCompletedFirstLoad = false

    private let observeFeed: ObserveFeedUseCase
    private let refreshFeed: RefreshFeedUseCase
    private let likePost: LikePostUseCase
    private let bookmarkPost: BookmarkPostUseCase

    init(
        observeFeed: ObserveFeedUseCase,
        refreshFeed: RefreshFeedUseCase,
        likePost: LikePostUseCase,
        bookmarkPost: BookmarkPostUseCase
    ) {
        self.observeFeed = observeFeed
        self.refreshFeed = refreshFeed
        self.likePost = likePost
        self.bookmarkPost = bookmarkPost
    }

    /// Consumes the cache stream for the caller's lifetime (cancelled when the
    /// view disappears). Keeps the list in sync with like/bookmark changes.
    func observe() async {
        for await posts in observeFeed() {
            self.posts = posts
            recomputeState()
        }
    }

    /// Runs the first API refresh exactly once.
    func refreshIfNeeded() async {
        guard !didFirstLoad else { return }
        didFirstLoad = true
        await refresh()
    }

    func refresh() async {
        if posts.isEmpty { state = .loading }
        do {
            let result = try await refreshFeed(page: 0)
            currentPage = 0
            posts = result.posts
            canLoadMore = result.fetchedCount >= FeedPaging.pageSize
            hasCompletedFirstLoad = true
            recomputeState()
        } catch {
            hasCompletedFirstLoad = true
            if posts.isEmpty {
                state = .error(Self.message(for: error))
            }
        }
    }

    func loadMore() async {
        guard canLoadMore, !isLoadingMore, !posts.isEmpty else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        do {
            let next = currentPage + 1
            let result = try await refreshFeed(page: next)
            currentPage = next
            posts = result.posts
            canLoadMore = result.fetchedCount >= FeedPaging.pageSize
            recomputeState()
        } catch {
            // Keep current posts; the user can pull to refresh to retry.
        }
    }

    func toggleLike(_ post: Post) {
        try? likePost(postId: post.id, isLiked: !post.isLiked)
    }

    func toggleBookmark(_ post: Post) {
        try? bookmarkPost(postId: post.id, isBookmarked: !post.isBookmarked)
    }

    private func recomputeState() {
        if !posts.isEmpty {
            state = .loaded(posts)
        } else if hasCompletedFirstLoad {
            state = .empty
        } else {
            state = .loading
        }
    }

    private static func message(for error: Error) -> String {
        (error as? AppError)?.message ?? AppError.unknown.message
    }
}
