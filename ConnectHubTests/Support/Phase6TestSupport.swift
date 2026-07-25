//
//  Phase6TestSupport.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation
@testable import ConnectHub

// MARK: - Service stubs

struct StubChatService: ChatService {
    var conversationDTOs: [ConversationDTO] = []
    var messageDTOs: [String: [MessageDTO]] = [:]
    var replyText = "Auto reply"

    func conversations() async throws -> [ConversationDTO] { conversationDTOs }

    func messages(conversationId: String) async throws -> [MessageDTO] {
        messageDTOs[conversationId] ?? []
    }

    func sendMessage(conversationId: String, text: String) async throws -> MessageDTO {
        MessageDTO(id: "sent", conversationId: conversationId, senderId: "me", text: text,
                   createdAt: Date(timeIntervalSince1970: 1_700_000_000), isMine: true)
    }

    func simulatedReply(to text: String) async throws -> MessageDTO {
        MessageDTO(id: "reply", conversationId: "", senderId: "them", text: replyText,
                   createdAt: Date(timeIntervalSince1970: 1_700_000_500), isMine: false)
    }
}

struct StubNotificationService: NotificationService {
    var dtos: [NotificationDTO] = []
    func notifications() async throws -> [NotificationDTO] { dtos }
}

// MARK: - Repository stub

@MainActor
final class StubNotificationRepository: NotificationRepository {
    var notifications: [AppNotification] = []
    private(set) var markReadIds: [String] = []
    private(set) var markAllReadCalled = false
    private var continuations: [UUID: AsyncStream<[AppNotification]>.Continuation] = [:]

    func notificationsStream() -> AsyncStream<[AppNotification]> {
        let (stream, continuation) = AsyncStream<[AppNotification]>.makeStream()
        let id = UUID()
        continuations[id] = continuation
        continuation.yield(notifications)
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor in self?.continuations[id] = nil }
        }
        return stream
    }

    func refresh() async throws {}

    func markRead(id: String) {
        markReadIds.append(id)
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications[index].isRead = true
        }
        emit()
    }

    func markAllRead() {
        markAllReadCalled = true
        for index in notifications.indices { notifications[index].isRead = true }
        emit()
    }

    private func emit() {
        for continuation in continuations.values { continuation.yield(notifications) }
    }
}

// MARK: - Sample factories

extension Message {
    static func sample(id: String = "m1", conversationId: String = "c1",
                       isMine: Bool = true, text: String = "Hi") -> Message {
        Message(id: id, conversationId: conversationId, senderId: isMine ? "me" : "them",
                text: text, createdAt: Date(timeIntervalSince1970: 1_700_000_000), isMine: isMine)
    }
}

extension MessageDTO {
    static func sample(id: String = "m1", conversationId: String = "c1", isMine: Bool = false) -> MessageDTO {
        MessageDTO(id: id, conversationId: conversationId, senderId: isMine ? "me" : "them",
                   text: "Message \(id)", createdAt: Date(timeIntervalSince1970: 1_700_000_000), isMine: isMine)
    }
}

extension ConversationDTO {
    static func sample(id: String = "c1", unreadCount: Int = 0) -> ConversationDTO {
        ConversationDTO(
            id: id,
            participant: UserDTO(id: "u_\(id)", name: "Partner \(id)", email: nil, avatarURL: nil,
                                 bio: nil, followersCount: 0, followingCount: 0),
            lastMessage: "Last message",
            unreadCount: unreadCount,
            updatedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )
    }
}

extension NotificationDTO {
    static func sample(id: String = "n1", kind: String = "like", isRead: Bool = false) -> NotificationDTO {
        NotificationDTO(id: id, kind: kind, text: "Notification \(id)",
                        createdAt: Date(timeIntervalSince1970: 1_700_000_000), isRead: isRead)
    }
}

extension AppNotification {
    static func sample(id: String = "n1", kind: Kind = .like, isRead: Bool = false) -> AppNotification {
        AppNotification(id: id, kind: kind, text: "Notification \(id)",
                        createdAt: Date(timeIntervalSince1970: 1_700_000_000), isRead: isRead)
    }
}
