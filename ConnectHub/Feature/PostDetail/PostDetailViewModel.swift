//
//  PostDetailViewModel.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Drives Post Detail: observes the cached post and its comments, refreshes both
/// from the API, and handles like/bookmark plus adding a comment inline.
@MainActor
@Observable
final class PostDetailViewModel {
    private(set) var post: Post?
    private(set) var comments: [Comment] = []
    private(set) var isLoading = true
    private(set) var errorMessage: String?

    var commentInput = ""
    private(set) var isSendingComment = false

    let postId: String

    private let observePost: ObservePostUseCase
    private let getDetails: GetPostDetailsUseCase
    private let observeComments: ObserveCommentsUseCase
    private let refreshComments: RefreshCommentsUseCase
    private let addComment: AddCommentUseCase
    private let likePost: LikePostUseCase
    private let bookmarkPost: BookmarkPostUseCase

    init(
        postId: String,
        observePost: ObservePostUseCase,
        getDetails: GetPostDetailsUseCase,
        observeComments: ObserveCommentsUseCase,
        refreshComments: RefreshCommentsUseCase,
        addComment: AddCommentUseCase,
        likePost: LikePostUseCase,
        bookmarkPost: BookmarkPostUseCase
    ) {
        self.postId = postId
        self.observePost = observePost
        self.getDetails = getDetails
        self.observeComments = observeComments
        self.refreshComments = refreshComments
        self.addComment = addComment
        self.likePost = likePost
        self.bookmarkPost = bookmarkPost
    }

    func observePostStream() async {
        for await post in observePost(id: postId) {
            self.post = post
            isLoading = false
        }
    }

    func observeCommentsStream() async {
        for await comments in observeComments(postId: postId) {
            self.comments = comments
        }
    }

    func load() async {
        do {
            try await getDetails(id: postId)
        } catch {
            if post == nil { errorMessage = Self.message(for: error) }
        }
        isLoading = false
        _ = try? await refreshComments(postId: postId)
    }

    func toggleLike() {
        guard let post else { return }
        try? likePost(postId: post.id, isLiked: !post.isLiked)
    }

    func toggleBookmark() {
        guard let post else { return }
        try? bookmarkPost(postId: post.id, isBookmarked: !post.isBookmarked)
    }

    func sendComment() async {
        let text = commentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSendingComment else { return }
        isSendingComment = true
        defer { isSendingComment = false }
        do {
            _ = try await addComment(postId: postId, text: text)
            commentInput = ""
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    private static func message(for error: Error) -> String {
        (error as? AppError)?.message ?? AppError.unknown.message
    }
}
