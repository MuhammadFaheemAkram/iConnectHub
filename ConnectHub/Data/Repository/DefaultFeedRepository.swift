//
//  DefaultFeedRepository.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation
import SwiftData

/// Offline-first posts repository backed by SwiftData. Owns the single posts
/// store and satisfies both the feed-list boundary (`FeedRepository`) and the
/// single-post boundary (`PostRepository`), so likes, bookmarks, comment counts,
/// and newly created posts stay in sync across the feed and detail screens.
///
/// - The cache (SwiftData) is the source of truth the UI observes.
/// - `refresh` pulls from the fake service and upserts into the cache,
///   preserving local like/bookmark state on posts that already exist.
/// - Every mutation re-queries the cache and emits to both list and per-post
///   observers.
@MainActor
final class DefaultFeedRepository: FeedRepository, PostRepository {
    private let service: FeedService
    /// Held strongly so the store outlives the repository; the context is the
    /// container's main context (dropping the container invalidates the context).
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }
    private var continuations: [UUID: AsyncStream<[Post]>.Continuation] = [:]
    private var postContinuations: [UUID: (id: String, continuation: AsyncStream<Post?>.Continuation)] = [:]

    init(service: FeedService, container: ModelContainer) {
        self.service = service
        self.container = container
    }

    func postsStream() -> AsyncStream<[Post]> {
        let (stream, continuation) = AsyncStream<[Post]>.makeStream()
        let id = UUID()
        continuations[id] = continuation
        continuation.yield(currentPosts())
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor in self?.continuations[id] = nil }
        }
        return stream
    }

    @discardableResult
    func refresh(page: Int) async throws -> FeedRefreshResult {
        let dtos = try await service.feed(page: page)
        for dto in dtos { upsert(dto) }
        try context.save()
        let posts = currentPosts()
        emit(posts)
        return FeedRefreshResult(posts: posts, fetchedCount: dtos.count)
    }

    func setLiked(postId: String, isLiked: Bool) throws {
        guard let entity = entity(id: postId) else { return }
        if isLiked, !entity.isLiked {
            entity.likeCount += 1
        } else if !isLiked, entity.isLiked {
            entity.likeCount = max(0, entity.likeCount - 1)
        }
        entity.isLiked = isLiked
        try context.save()
        emit(currentPosts())
    }

    func setBookmarked(postId: String, isBookmarked: Bool) throws {
        guard let entity = entity(id: postId) else { return }
        entity.isBookmarked = isBookmarked
        try context.save()
        emit(currentPosts())
    }

    // MARK: - PostRepository

    func observePost(id: String) -> AsyncStream<Post?> {
        let (stream, continuation) = AsyncStream<Post?>.makeStream()
        let key = UUID()
        postContinuations[key] = (id, continuation)
        continuation.yield(currentPosts().first { $0.id == id })
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor in self?.postContinuations[key] = nil }
        }
        return stream
    }

    func refreshDetails(id: String) async throws {
        let dto = try await service.postDetails(id: id)
        upsert(dto)
        try context.save()
        emit(currentPosts())
    }

    @discardableResult
    func createPost(content: String, imageURL: URL?, author: User) async throws -> Post {
        let entity = PostEntity(
            id: "p_\(UUID().uuidString.prefix(8))",
            authorId: author.id,
            authorName: author.name,
            authorAvatarURLString: author.avatarURL?.absoluteString,
            authorBio: author.bio,
            authorFollowersCount: author.followersCount,
            authorFollowingCount: author.followingCount,
            content: content,
            imageURLString: imageURL?.absoluteString,
            createdAt: Date(),
            likeCount: 0,
            commentCount: 0,
            isLiked: false,
            isBookmarked: false
        )
        context.insert(entity)
        try context.save()
        emit(currentPosts())
        return PostMapper.toDomain(entity)
    }

    func adjustCommentCount(postId: String, delta: Int) throws {
        guard let entity = entity(id: postId) else { return }
        entity.commentCount = max(0, entity.commentCount + delta)
        try context.save()
        emit(currentPosts())
    }

    // MARK: - Cache access

    private func currentPosts() -> [Post] {
        let descriptor = FetchDescriptor<PostEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let entities = (try? context.fetch(descriptor)) ?? []
        return entities.map(PostMapper.toDomain)
    }

    private func entity(id: String) -> PostEntity? {
        var descriptor = FetchDescriptor<PostEntity>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    /// Insert new posts; for existing posts, refresh server-owned fields but
    /// keep local like/bookmark state (and the locally adjusted like count).
    private func upsert(_ dto: PostDTO) {
        if let existing = entity(id: dto.id) {
            existing.content = dto.content
            existing.imageURLString = dto.imageURL
            existing.commentCount = dto.commentCount
            existing.createdAt = dto.createdAt
            existing.authorName = dto.author.name
            existing.authorAvatarURLString = dto.author.avatarURL
            existing.authorBio = dto.author.bio ?? ""
            existing.authorFollowersCount = dto.author.followersCount
            existing.authorFollowingCount = dto.author.followingCount
        } else {
            context.insert(PostMapper.makeEntity(from: dto))
        }
    }

    private func emit(_ posts: [Post]) {
        for continuation in continuations.values {
            continuation.yield(posts)
        }
        for (_, entry) in postContinuations {
            entry.continuation.yield(posts.first { $0.id == entry.id })
        }
    }
}
