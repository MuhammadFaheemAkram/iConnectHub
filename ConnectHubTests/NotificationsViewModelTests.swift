//
//  NotificationsViewModelTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
@testable import ConnectHub

@MainActor
struct NotificationsViewModelTests {

    private func makeViewModel(_ repo: StubNotificationRepository) -> NotificationsViewModel {
        NotificationsViewModel(
            observeNotifications: ObserveNotificationsUseCase(repository: repo),
            refreshNotifications: RefreshNotificationsUseCase(repository: repo),
            markRead: MarkNotificationReadUseCase(repository: repo),
            markAllRead: MarkAllNotificationsReadUseCase(repository: repo)
        )
    }

    @Test func markReadForwardsForUnreadNotification() {
        let repo = StubNotificationRepository()
        let model = makeViewModel(repo)

        model.markRead(.sample(id: "n1", isRead: false))

        #expect(repo.markReadIds == ["n1"])
    }

    @Test func markReadSkipsAlreadyReadNotification() {
        let repo = StubNotificationRepository()
        let model = makeViewModel(repo)

        model.markRead(.sample(id: "n1", isRead: true))

        #expect(repo.markReadIds.isEmpty)
    }

    @Test func markAllReadForwardsToRepository() {
        let repo = StubNotificationRepository()
        let model = makeViewModel(repo)

        model.markAllRead()

        #expect(repo.markAllReadCalled)
    }
}
