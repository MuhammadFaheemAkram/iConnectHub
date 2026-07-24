//
//  BookmarksViewModel.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Drives the Bookmarks screen. Observes bookmarked posts from the offline cache
/// and removes bookmarks. No network — bookmarks are purely local state.
@MainActor
@Observable
final class BookmarksViewModel {
    enum State: Equatable {
        case loading
        case empty
        case loaded([Post])
    }

    private(set) var state: State = .loading

    private var posts: [Post] = []
    private var hasLoaded = false

    private let observeBookmarks: ObserveBookmarksUseCase
    private let bookmarkPost: BookmarkPostUseCase
    private let likePost: LikePostUseCase

    init(
        observeBookmarks: ObserveBookmarksUseCase,
        bookmarkPost: BookmarkPostUseCase,
        likePost: LikePostUseCase
    ) {
        self.observeBookmarks = observeBookmarks
        self.bookmarkPost = bookmarkPost
        self.likePost = likePost
    }

    func observe() async {
        for await posts in observeBookmarks() {
            self.posts = posts
            hasLoaded = true
            recomputeState()
        }
    }

    func removeBookmark(_ post: Post) {
        try? bookmarkPost(postId: post.id, isBookmarked: false)
    }

    func toggleLike(_ post: Post) {
        try? likePost(postId: post.id, isLiked: !post.isLiked)
    }

    private func recomputeState() {
        if !posts.isEmpty {
            state = .loaded(posts)
        } else if hasLoaded {
            state = .empty
        } else {
            state = .loading
        }
    }
}
