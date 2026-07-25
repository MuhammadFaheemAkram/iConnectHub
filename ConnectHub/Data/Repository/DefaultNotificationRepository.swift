//
//  DefaultNotificationRepository.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Default notifications repository. Holds notifications in memory (seeded from
/// the fake service) and exposes read-state mutations via an `AsyncStream`.
@MainActor
final class DefaultNotificationRepository: NotificationRepository {
    private let service: NotificationService
    private var notifications: [AppNotification] = []
    private var continuations: [UUID: AsyncStream<[AppNotification]>.Continuation] = [:]

    init(service: NotificationService) {
        self.service = service
    }

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

    func refresh() async throws {
        let dtos = try await service.notifications()
        notifications = dtos.map(NotificationMapper.toDomain)
        emit()
    }

    func markRead(id: String) {
        guard let index = notifications.firstIndex(where: { $0.id == id }) else { return }
        notifications[index].isRead = true
        emit()
    }

    func markAllRead() {
        for index in notifications.indices { notifications[index].isRead = true }
        emit()
    }

    private func emit() {
        for continuation in continuations.values { continuation.yield(notifications) }
    }
}
