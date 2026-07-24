//
//  CommentTestSupport.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation
import SwiftData
@testable import ConnectHub

// MARK: - Service stubs

struct StubCommentService: CommentService {
    var commentsByPost: [String: [CommentDTO]] = [:]
    var error: AppError?

    func comments(postId: String) async throws -> [CommentDTO] {
        if let error { throw error }
        return commentsByPost[postId] ?? []
    }

    func addComment(postId: String, text: String) async throws -> CommentDTO {
        if let error { throw error }
        return CommentDTO(
            id: "srv_\(UUID().uuidString.prefix(6))",
            postId: postId,
            author: UserDTO(id: "me", name: "You", email: nil, avatarURL: nil,
                            bio: nil, followersCount: 0, followingCount: 0),
            text: text,
            createdAt: Date(timeIntervalSince1970: 1_700_000_100)
        )
    }
}

// MARK: - Repository stubs

/// Comment repository fake for view-model tests.
@MainActor
final class StubCommentRepository: CommentRepository {
    var commentsToReturn: [Comment] = []
    var refreshError: AppError?
    private(set) var addedTexts: [String] = []
    private(set) var deletedIds: [String] = []

    private var continuations: [UUID: AsyncStream<[Comment]>.Continuation] = [:]

    func observeComments(postId: String) -> AsyncStream<[Comment]> {
        let (stream, continuation) = AsyncStream<[Comment]>.makeStream()
        let id = UUID()
        continuations[id] = continuation
        continuation.yield(commentsToReturn)
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor in self?.continuations[id] = nil }
        }
        return stream
    }

    @discardableResult
    func refresh(postId: String) async throws -> [Comment] {
        if let refreshError { throw refreshError }
        return commentsToReturn
    }

    func add(postId: String, text: String, author: User) async throws -> Comment {
        addedTexts.append(text)
        let comment = Comment(id: "new_\(addedTexts.count)", postId: postId, author: author,
                              text: text, createdAt: Date(timeIntervalSince1970: 1_700_000_200),
                              isOwnComment: true)
        commentsToReturn.append(comment)
        emit()
        return comment
    }

    func delete(commentId: String) throws {
        deletedIds.append(commentId)
        commentsToReturn.removeAll { $0.id == commentId }
        emit()
    }

    private func emit() {
        for continuation in continuations.values { continuation.yield(commentsToReturn) }
    }
}

/// Post repository fake for create-post view-model tests.
@MainActor
final class StubPostRepository: PostRepository {
    private(set) var createdContents: [String] = []
    private(set) var commentCountDeltas: [(postId: String, delta: Int)] = []
    var createError: AppError?

    func observePost(id: String) -> AsyncStream<Post?> {
        AsyncStream { $0.finish() }
    }

    func refreshDetails(id: String) async throws {}

    @discardableResult
    func createPost(content: String, imageURL: URL?, author: User) async throws -> Post {
        if let createError { throw createError }
        createdContents.append(content)
        return Post(id: "created", author: author, content: content, imageURL: imageURL,
                    createdAt: Date(timeIntervalSince1970: 1_700_000_300),
                    likeCount: 0, commentCount: 0, isLiked: false, isBookmarked: false)
    }

    func adjustCommentCount(postId: String, delta: Int) throws {
        commentCountDeltas.append((postId, delta))
    }
}

// MARK: - Sample factories

extension Comment {
    static func sample(id: String = "c1", postId: String = "p1", isOwn: Bool = false) -> Comment {
        Comment(id: id, postId: postId, author: .sample(), text: "Sample comment \(id)",
                createdAt: Date(timeIntervalSince1970: 1_700_000_000), isOwnComment: isOwn)
    }
}

extension CommentDTO {
    static func sample(id: String = "c1", postId: String = "p1") -> CommentDTO {
        CommentDTO(id: id, postId: postId,
                   author: UserDTO(id: "u1", name: "Ada", email: nil, avatarURL: nil,
                                   bio: "b", followersCount: 0, followingCount: 0),
                   text: "DTO comment \(id)",
                   createdAt: Date(timeIntervalSince1970: 1_700_000_000))
    }
}

// MARK: - Helpers

/// A real `DefaultCommentRepository` over an isolated in-memory SwiftData store.
@MainActor
func makeInMemoryCommentRepository(service: CommentService) -> DefaultCommentRepository {
    DefaultCommentRepository(service: service, container: PersistenceController.makeContainer(inMemory: true))
}

/// The first value emitted by a stream (streams here yield the current value on
/// subscribe, so this reads the current cache snapshot).
func firstValue<T: Sendable>(_ stream: AsyncStream<T>) async -> T? {
    for await value in stream { return value }
    return nil
}
