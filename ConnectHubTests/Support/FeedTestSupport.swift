//
//  FeedTestSupport.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation
import SwiftData
@testable import ConnectHub

// MARK: - Test doubles

/// Configurable `FeedService` fake with fixed pages and an optional error.
struct StubFeedService: FeedService {
    var pages: [[PostDTO]] = []
    var error: AppError?

    func feed(page: Int) async throws -> [PostDTO] {
        if let error { throw error }
        return page < pages.count ? pages[page] : []
    }

    func postDetails(id: String) async throws -> PostDTO {
        if let error { throw error }
        for page in pages {
            if let match = page.first(where: { $0.id == id }) { return match }
        }
        throw AppError.notFound
    }
}

/// In-memory `FeedRepository` fake for view-model tests: controls the refresh
/// result and records like/bookmark calls.
@MainActor
final class StubFeedRepository: FeedRepository {
    var refreshResult = FeedRefreshResult(posts: [], fetchedCount: 0)
    var refreshError: AppError?
    private(set) var likedCalls: [(id: String, isLiked: Bool)] = []
    private(set) var bookmarkedCalls: [(id: String, isBookmarked: Bool)] = []

    private var continuations: [UUID: AsyncStream<[Post]>.Continuation] = [:]

    func postsStream() -> AsyncStream<[Post]> {
        let (stream, continuation) = AsyncStream<[Post]>.makeStream()
        let id = UUID()
        continuations[id] = continuation
        continuation.yield(refreshResult.posts)
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor in self?.continuations[id] = nil }
        }
        return stream
    }

    func refresh(page: Int) async throws -> FeedRefreshResult {
        if let refreshError { throw refreshError }
        return refreshResult
    }

    func setLiked(postId: String, isLiked: Bool) throws {
        likedCalls.append((postId, isLiked))
    }

    func setBookmarked(postId: String, isBookmarked: Bool) throws {
        bookmarkedCalls.append((postId, isBookmarked))
    }

    func clearCache() throws {}
}

// MARK: - Sample factories

extension Post {
    static func sample(
        id: String = "p1",
        isLiked: Bool = false,
        isBookmarked: Bool = false,
        likeCount: Int = 10
    ) -> Post {
        Post(id: id, author: .sample(), content: "Sample post \(id)", imageURL: nil,
             createdAt: Date(timeIntervalSince1970: 1_700_000_000),
             likeCount: likeCount, commentCount: 3,
             isLiked: isLiked, isBookmarked: isBookmarked)
    }
}

extension PostDTO {
    static func sample(id: String = "p1", likeCount: Int = 10) -> PostDTO {
        PostDTO(id: id,
                author: UserDTO(id: "u1", name: "Ada", email: nil, avatarURL: nil,
                                bio: "bio", followersCount: 1, followingCount: 2),
                content: "Content \(id)", imageURL: nil,
                createdAt: Date(timeIntervalSince1970: 1_700_000_000),
                likeCount: likeCount, commentCount: 3)
    }
}

// MARK: - Helpers

/// A real `DefaultFeedRepository` over an isolated in-memory SwiftData store.
/// The repository retains the container, so it lives for the repo's lifetime.
@MainActor
func makeInMemoryFeedRepository(service: FeedService) -> DefaultFeedRepository {
    let container = PersistenceController.makeContainer(inMemory: true)
    return DefaultFeedRepository(service: service, container: container)
}
