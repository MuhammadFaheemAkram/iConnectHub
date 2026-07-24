//
//  CommentsViewModelTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
@testable import ConnectHub

@MainActor
struct CommentsViewModelTests {

    private func makeViewModel(_ repo: StubCommentRepository) -> CommentsViewModel {
        let session = makeEphemeralSessionRepository()
        session.save(.sample())
        let postRepo = StubPostRepository()
        return CommentsViewModel(
            postId: "p1",
            observeComments: ObserveCommentsUseCase(repository: repo),
            refreshComments: RefreshCommentsUseCase(repository: repo),
            addComment: AddCommentUseCase(commentRepository: repo, postRepository: postRepo, sessionRepository: session),
            deleteComment: DeleteCommentUseCase(commentRepository: repo, postRepository: postRepo)
        )
    }

    @Test func refreshLoadsComments() async {
        let repo = StubCommentRepository()
        repo.commentsToReturn = [.sample(id: "a"), .sample(id: "b")]
        let model = makeViewModel(repo)

        await model.refresh()

        #expect(model.state == .loaded([.sample(id: "a"), .sample(id: "b")]))
    }

    @Test func emptyRefreshShowsEmptyState() async {
        let repo = StubCommentRepository()
        let model = makeViewModel(repo)

        await model.refresh()

        #expect(model.state == .empty)
    }

    @Test func refreshErrorShowsError() async {
        let repo = StubCommentRepository()
        repo.refreshError = .network
        let model = makeViewModel(repo)

        await model.refresh()

        #expect(model.state == .error(AppError.network.message))
    }

    @Test func sendForwardsTrimmedTextAndClearsInput() async {
        let repo = StubCommentRepository()
        let model = makeViewModel(repo)
        model.input = "  Nice post!  "

        await model.send()

        #expect(repo.addedTexts == ["Nice post!"])
        #expect(model.input == "")
    }

    @Test func deleteOnlyForwardsForOwnComments() {
        let repo = StubCommentRepository()
        let model = makeViewModel(repo)

        model.delete(.sample(id: "x", isOwn: false))
        #expect(repo.deletedIds.isEmpty)

        model.delete(.sample(id: "y", isOwn: true))
        #expect(repo.deletedIds == ["y"])
    }
}
