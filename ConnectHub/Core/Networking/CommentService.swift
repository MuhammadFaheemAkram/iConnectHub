//
//  CommentService.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Service boundary for comments. `FakeCommentService` backs it with bundled
/// JSON; a real client could replace it behind this protocol.
protocol CommentService: Sendable {
    func comments(postId: String) async throws -> [CommentDTO]
    func addComment(postId: String, text: String) async throws -> CommentDTO
}
