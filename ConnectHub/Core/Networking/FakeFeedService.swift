//
//  FakeFeedService.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Fake `FeedService`: serves a bundled set of posts, sorted newest-first, in
/// pages. Simulates latency and offers an error toggle. A real client could
/// replace it behind the same protocol.
struct FakeFeedService: FeedService {
    private let shouldThrowError = false
    private let latency: Duration = .milliseconds(700)

    func feed(page: Int) async throws -> [PostDTO] {
        try await Task.sleep(for: latency)
        if shouldThrowError { throw AppError.network }

        let all = Self.allPosts()
        let start = page * FeedPaging.pageSize
        guard start < all.count else { return [] }
        let end = min(start + FeedPaging.pageSize, all.count)
        return Array(all[start..<end])
    }

    func postDetails(id: String) async throws -> PostDTO {
        try await Task.sleep(for: latency)
        if shouldThrowError { throw AppError.network }
        guard let post = Self.allPosts().first(where: { $0.id == id }) else {
            throw AppError.notFound
        }
        return post
    }

    /// Bundled posts, newest first. Falls back to an empty feed if the resource
    /// is somehow unavailable.
    private static func allPosts() -> [PostDTO] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let posts = (try? BundleJSON.decode([PostDTO].self, from: "feed_posts", decoder: decoder)) ?? []
        return posts.sorted { $0.createdAt > $1.createdAt }
    }
}
