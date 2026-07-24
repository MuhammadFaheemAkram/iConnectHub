//
//  DefaultCommentRepository.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation
import SwiftData

/// Offline-first comment repository backed by SwiftData. Comments are cached per
/// post and observed via `AsyncStream`; refresh upserts server comments while
/// leaving the user's own comments untouched.
@MainActor
final class DefaultCommentRepository: CommentRepository {
    private let service: CommentService
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }
    private var continuations: [UUID: (postId: String, continuation: AsyncStream<[Comment]>.Continuation)] = [:]

    init(service: CommentService, container: ModelContainer) {
        self.service = service
        self.container = container
    }

    func observeComments(postId: String) -> AsyncStream<[Comment]> {
        let (stream, continuation) = AsyncStream<[Comment]>.makeStream()
        let key = UUID()
        continuations[key] = (postId, continuation)
        continuation.yield(comments(for: postId))
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor in self?.continuations[key] = nil }
        }
        return stream
    }

    @discardableResult
    func refresh(postId: String) async throws -> [Comment] {
        let dtos = try await service.comments(postId: postId)
        for dto in dtos { upsert(dto) }
        try context.save()
        let comments = comments(for: postId)
        emit(postId: postId)
        return comments
    }

    func add(postId: String, text: String, author: User) async throws -> Comment {
        let dto = try await service.addComment(postId: postId, text: text)
        let entity = CommentEntity(
            id: dto.id,
            postId: postId,
            authorId: author.id,
            authorName: author.name,
            authorAvatarURLString: author.avatarURL?.absoluteString,
            text: text,
            createdAt: dto.createdAt,
            isOwnComment: true
        )
        context.insert(entity)
        try context.save()
        emit(postId: postId)
        return CommentMapper.toDomain(entity)
    }

    func delete(commentId: String) throws {
        guard let entity = entity(id: commentId) else { return }
        let postId = entity.postId
        context.delete(entity)
        try context.save()
        emit(postId: postId)
    }

    // MARK: - Cache access

    private func comments(for postId: String) -> [Comment] {
        let descriptor = FetchDescriptor<CommentEntity>(
            predicate: #Predicate { $0.postId == postId },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        let entities = (try? context.fetch(descriptor)) ?? []
        return entities.map(CommentMapper.toDomain)
    }

    private func entity(id: String) -> CommentEntity? {
        var descriptor = FetchDescriptor<CommentEntity>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    /// Server comments are never "own"; update text if present, else insert.
    private func upsert(_ dto: CommentDTO) {
        if let existing = entity(id: dto.id) {
            existing.text = dto.text
        } else {
            context.insert(CommentMapper.makeEntity(from: dto, isOwnComment: false))
        }
    }

    private func emit(postId: String) {
        let comments = comments(for: postId)
        for entry in continuations.values where entry.postId == postId {
            entry.continuation.yield(comments)
        }
    }
}
