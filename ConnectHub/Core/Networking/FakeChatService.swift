//
//  FakeChatService.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Fake `ChatService`: bundled conversations and messages, an echoed send, and a
/// delayed canned reply that powers the typing indicator.
struct FakeChatService: ChatService {
    private let shouldThrowError = false
    private let latency: Duration = .milliseconds(400)
    private let replyDelay: Duration = .milliseconds(1500)

    func conversations() async throws -> [ConversationDTO] {
        try await Task.sleep(for: latency)
        if shouldThrowError { throw AppError.network }
        let dtos = (try? BundleJSON.decode([ConversationDTO].self, from: "conversations", decoder: Self.decoder)) ?? []
        return dtos.sorted { $0.updatedAt > $1.updatedAt }
    }

    func messages(conversationId: String) async throws -> [MessageDTO] {
        try await Task.sleep(for: latency)
        if shouldThrowError { throw AppError.network }
        let dtos = (try? BundleJSON.decode([MessageDTO].self, from: "messages", decoder: Self.decoder)) ?? []
        return dtos.filter { $0.conversationId == conversationId }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func sendMessage(conversationId: String, text: String) async throws -> MessageDTO {
        try await Task.sleep(for: latency)
        if shouldThrowError { throw AppError.network }
        return MessageDTO(
            id: "m_\(UUID().uuidString.prefix(8))",
            conversationId: conversationId,
            senderId: "me",
            text: text,
            createdAt: Date(),
            isMine: true
        )
    }

    func simulatedReply(to text: String) async throws -> MessageDTO {
        try await Task.sleep(for: replyDelay)
        if shouldThrowError { throw AppError.network }
        let reply = text.contains("?")
            ? "Good question — let me think about that. 🤔"
            : (Self.replies.randomElement() ?? "Got it!")
        return MessageDTO(
            id: "m_\(UUID().uuidString.prefix(8))",
            conversationId: "",
            senderId: "them",
            text: reply,
            createdAt: Date(),
            isMine: false
        )
    }

    private static let replies = [
        "Sounds good! 👍",
        "Ha, totally agree.",
        "Let me get back to you on that.",
        "Nice — thanks for the update!",
        "Interesting, tell me more.",
        "On it. 🚀",
        "That makes sense to me.",
        "Great point!"
    ]

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
