//
//  PostInteractionTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
import Foundation
@testable import ConnectHub

/// SwiftData-backed tests for single-post operations and the add-comment use
/// case (which spans the comment and post repositories). Serialized per store.
@MainActor
@Suite(.serialized)
struct PostInteractionTests {

    @Test func createPostInsertsAndIsObservable() async throws {
        let repo = makeInMemoryFeedRepository(service: StubFeedService())

        let created = try await repo.createPost(content: "Brand new post", imageURL: nil, author: .sample())

        #expect(created.content == "Brand new post")
        #expect(created.likeCount == 0)
        let observed = (await firstValue(repo.observePost(id: created.id))).flatMap { $0 }
        #expect(observed?.content == "Brand new post")
    }

    @Test func createdPostAppearsAtTopOfFeed() async throws {
        let service = StubFeedService(pages: [[.sample(id: "old")]])
        let repo = makeInMemoryFeedRepository(service: service)
        _ = try await repo.refresh(page: 0)

        let created = try await repo.createPost(content: "Newest", imageURL: nil, author: .sample())

        // The feed is newest-first, so the just-created post leads.
        let feed = await firstValue(repo.postsStream()) ?? []
        #expect(feed.first?.id == created.id)
    }

    @Test func adjustCommentCountUpdatesPost() async throws {
        let service = StubFeedService(pages: [[.sample(id: "p1")]]) // commentCount 3
        let repo = makeInMemoryFeedRepository(service: service)
        _ = try await repo.refresh(page: 0)

        try repo.adjustCommentCount(postId: "p1", delta: 1)

        let observed = (await firstValue(repo.observePost(id: "p1"))).flatMap { $0 }
        #expect(observed?.commentCount == 4)
    }

    @Test func addCommentUseCaseInsertsCommentAndBumpsCount() async throws {
        // Post and comment repositories share one store so the post exists.
        let container = PersistenceController.makeContainer(inMemory: true)
        let postRepo = DefaultFeedRepository(
            service: StubFeedService(pages: [[.sample(id: "p1")]]),
            container: container
        )
        let commentRepo = DefaultCommentRepository(service: StubCommentService(), container: container)
        _ = try await postRepo.refresh(page: 0) // p1, commentCount 3

        let session = makeEphemeralSessionRepository()
        session.save(.sample())
        let addComment = AddCommentUseCase(
            commentRepository: commentRepo,
            postRepository: postRepo,
            sessionRepository: session
        )

        _ = try await addComment(postId: "p1", text: "Great post")

        let comments = await firstValue(commentRepo.observeComments(postId: "p1")) ?? []
        #expect(comments.contains { $0.text == "Great post" && $0.isOwnComment })
        let post = (await firstValue(postRepo.observePost(id: "p1"))).flatMap { $0 }
        #expect(post?.commentCount == 4)
    }

    @Test func deleteCommentUseCaseRemovesAndLowersCount() async throws {
        let container = PersistenceController.makeContainer(inMemory: true)
        let postRepo = DefaultFeedRepository(
            service: StubFeedService(pages: [[.sample(id: "p1")]]),
            container: container
        )
        let commentRepo = DefaultCommentRepository(service: StubCommentService(), container: container)
        _ = try await postRepo.refresh(page: 0)
        let comment = try await commentRepo.add(postId: "p1", text: "mine", author: .sample())
        try postRepo.adjustCommentCount(postId: "p1", delta: 1) // now 4

        let deleteComment = DeleteCommentUseCase(commentRepository: commentRepo, postRepository: postRepo)
        try deleteComment(commentId: comment.id, postId: "p1")

        let comments = await firstValue(commentRepo.observeComments(postId: "p1")) ?? []
        #expect(comments.isEmpty)
        let post = (await firstValue(postRepo.observePost(id: "p1"))).flatMap { $0 }
        #expect(post?.commentCount == 3)
    }
}
