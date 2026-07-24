//
//  CommentRepositoryTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
import Foundation
@testable import ConnectHub

/// Serialized: each test builds its own SwiftData store.
@MainActor
@Suite(.serialized)
struct CommentRepositoryTests {

    @Test func refreshLoadsSeedCommentsForPost() async throws {
        let service = StubCommentService(commentsByPost: [
            "p1": [.sample(id: "a", postId: "p1"), .sample(id: "b", postId: "p1")],
            "p2": [.sample(id: "c", postId: "p2")]
        ])
        let repo = makeInMemoryCommentRepository(service: service)

        let comments = try await repo.refresh(postId: "p1")

        #expect(comments.count == 2)
        #expect(Set(comments.map(\.id)) == ["a", "b"])
    }

    @Test func addInsertsOwnComment() async throws {
        let repo = makeInMemoryCommentRepository(service: StubCommentService())

        let comment = try await repo.add(postId: "p1", text: "First!", author: .sample())

        #expect(comment.isOwnComment)
        #expect(comment.text == "First!")
        let current = await firstValue(repo.observeComments(postId: "p1")) ?? []
        #expect(current.count == 1)
    }

    @Test func deleteRemovesComment() async throws {
        let repo = makeInMemoryCommentRepository(service: StubCommentService())
        let comment = try await repo.add(postId: "p1", text: "Oops", author: .sample())

        try repo.delete(commentId: comment.id)

        let current = await firstValue(repo.observeComments(postId: "p1")) ?? []
        #expect(current.isEmpty)
    }

    @Test func ownCommentsSurviveRefresh() async throws {
        let service = StubCommentService(commentsByPost: ["p1": [.sample(id: "seed", postId: "p1")]])
        let repo = makeInMemoryCommentRepository(service: service)
        _ = try await repo.refresh(postId: "p1")
        _ = try await repo.add(postId: "p1", text: "mine", author: .sample())

        let after = try await repo.refresh(postId: "p1")

        #expect(after.count == 2)
        #expect(after.contains { $0.isOwnComment && $0.text == "mine" })
    }

    @Test func commentsAreScopedToTheirPost() async throws {
        let service = StubCommentService(commentsByPost: [
            "p1": [.sample(id: "a", postId: "p1")],
            "p2": [.sample(id: "b", postId: "p2"), .sample(id: "c", postId: "p2")]
        ])
        let repo = makeInMemoryCommentRepository(service: service)
        _ = try await repo.refresh(postId: "p1")
        _ = try await repo.refresh(postId: "p2")

        let p1 = await firstValue(repo.observeComments(postId: "p1")) ?? []
        let p2 = await firstValue(repo.observeComments(postId: "p2")) ?? []
        #expect(p1.count == 1)
        #expect(p2.count == 2)
    }
}
