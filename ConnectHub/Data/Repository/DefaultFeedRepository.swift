//
//  DefaultFeedRepository.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation
import SwiftData

/// Offline-first feed repository backed by SwiftData.
///
/// - The cache (SwiftData) is the source of truth the UI observes.
/// - `refresh` pulls from the fake service and upserts into the cache,
///   preserving local like/bookmark state on posts that already exist.
/// - Every mutation re-queries the cache and emits to observers.
@MainActor
final class DefaultFeedRepository: FeedRepository {
    private let service: FeedService
    /// Held strongly so the store outlives the repository; the context is the
    /// container's main context (dropping the container invalidates the context).
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }
    private var continuations: [UUID: AsyncStream<[Post]>.Continuation] = [:]

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
    }
}
