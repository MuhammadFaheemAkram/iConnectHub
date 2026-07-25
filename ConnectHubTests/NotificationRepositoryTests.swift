//
//  NotificationRepositoryTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
@testable import ConnectHub

@MainActor
struct NotificationRepositoryTests {

    @Test func refreshLoadsNotifications() async throws {
        let service = StubNotificationService(dtos: [.sample(id: "n1"), .sample(id: "n2", isRead: true)])
        let repo = DefaultNotificationRepository(service: service)

        try await repo.refresh()

        let notifications = await firstValue(repo.notificationsStream()) ?? []
        #expect(notifications.count == 2)
    }

    @Test func kindMapsFromRawString() async throws {
        let service = StubNotificationService(dtos: [.sample(id: "n1", kind: "follow")])
        let repo = DefaultNotificationRepository(service: service)
        try await repo.refresh()

        let notifications = await firstValue(repo.notificationsStream()) ?? []
        #expect(notifications.first?.kind == .follow)
    }

    @Test func markReadUpdatesSingleNotification() async throws {
        let service = StubNotificationService(dtos: [.sample(id: "n1", isRead: false)])
        let repo = DefaultNotificationRepository(service: service)
        try await repo.refresh()

        repo.markRead(id: "n1")

        let notifications = await firstValue(repo.notificationsStream()) ?? []
        #expect(notifications.first?.isRead == true)
    }

    @Test func markAllReadUpdatesEveryNotification() async throws {
        let service = StubNotificationService(dtos: [
            .sample(id: "n1", isRead: false), .sample(id: "n2", isRead: false)
        ])
        let repo = DefaultNotificationRepository(service: service)
        try await repo.refresh()

        repo.markAllRead()

        let notifications = await firstValue(repo.notificationsStream()) ?? []
        let allRead = notifications.allSatisfy { $0.isRead }
        #expect(allRead)
    }
}
