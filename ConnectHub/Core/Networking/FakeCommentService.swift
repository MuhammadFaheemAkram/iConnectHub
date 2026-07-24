//
//  FakeCommentService.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Fake `CommentService`: serves bundled comments filtered by post, and echoes
/// added comments back with a generated id. Simulates latency + error toggle.
struct FakeCommentService: CommentService {
    private let shouldThrowError = false
    private let latency: Duration = .milliseconds(500)

    func comments(postId: String) async throws -> [CommentDTO] {
        try await Task.sleep(for: latency)
        if shouldThrowError { throw AppError.network }
        return Self.allComments()
            .filter { $0.postId == postId }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func addComment(postId: String, text: String) async throws -> CommentDTO {
        try await Task.sleep(for: latency)
        if shouldThrowError { throw AppError.network }
        // The server assigns an id and timestamp; the caller supplies the author.
        return CommentDTO(
            id: "c_\(UUID().uuidString.prefix(8))",
            postId: postId,
            author: UserDTO(id: "me", name: "You", email: nil, avatarURL: nil,
                            bio: nil, followersCount: 0, followingCount: 0),
            text: text,
            createdAt: Date()
        )
    }

    private static func allComments() -> [CommentDTO] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? BundleJSON.decode([CommentDTO].self, from: "comments", decoder: decoder)) ?? []
    }
}
