//
//  CommentsViewModel.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Drives the Comments screen: observes the cached comments, refreshes from the
/// API, and handles adding and deleting own comments.
@MainActor
@Observable
final class CommentsViewModel {
    enum State: Equatable {
        case loading
        case empty
        case loaded([Comment])
        case error(String)
    }

    private(set) var state: State = .loading
    var input = ""
    private(set) var isSending = false

    let postId: String

    private let observeComments: ObserveCommentsUseCase
    private let refreshComments: RefreshCommentsUseCase
    private let addComment: AddCommentUseCase
    private let deleteComment: DeleteCommentUseCase

    private var comments: [Comment] = []
    private var didLoad = false
    private var hasCompletedFirstLoad = false

    init(
        postId: String,
        observeComments: ObserveCommentsUseCase,
        refreshComments: RefreshCommentsUseCase,
        addComment: AddCommentUseCase,
        deleteComment: DeleteCommentUseCase
    ) {
        self.postId = postId
        self.observeComments = observeComments
        self.refreshComments = refreshComments
        self.addComment = addComment
        self.deleteComment = deleteComment
    }

    func observe() async {
        for await comments in observeComments(postId: postId) {
            self.comments = comments
            recomputeState()
        }
    }

    func loadIfNeeded() async {
        guard !didLoad else { return }
        didLoad = true
        await refresh()
    }

    func refresh() async {
        if comments.isEmpty { state = .loading }
        do {
            comments = try await refreshComments(postId: postId)
            hasCompletedFirstLoad = true
            recomputeState()
        } catch {
            hasCompletedFirstLoad = true
            if comments.isEmpty {
                state = .error(Self.message(for: error))
            }
        }
    }

    func send() async {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSending else { return }
        isSending = true
        defer { isSending = false }
        do {
            _ = try await addComment(postId: postId, text: text)
            input = ""
        } catch {
            // Surface nothing intrusive; the comment simply isn't added.
        }
    }

    func delete(_ comment: Comment) {
        guard comment.isOwnComment else { return }
        try? deleteComment(commentId: comment.id, postId: postId)
    }

    private func recomputeState() {
        if !comments.isEmpty {
            state = .loaded(comments)
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
