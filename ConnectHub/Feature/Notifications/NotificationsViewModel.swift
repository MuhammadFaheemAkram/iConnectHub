//
//  NotificationsViewModel.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Drives the Notifications screen: observes notifications, refreshes, and marks
/// items read.
@MainActor
@Observable
final class NotificationsViewModel {
    enum State: Equatable {
        case loading
        case empty
        case loaded([AppNotification])
        case error(String)
    }

    private(set) var state: State = .loading

    private var notifications: [AppNotification] = []
    private var didLoad = false
    private var hasCompletedFirstLoad = false

    private let observeNotifications: ObserveNotificationsUseCase
    private let refreshNotifications: RefreshNotificationsUseCase
    private let markReadUseCase: MarkNotificationReadUseCase
    private let markAllReadUseCase: MarkAllNotificationsReadUseCase

    init(
        observeNotifications: ObserveNotificationsUseCase,
        refreshNotifications: RefreshNotificationsUseCase,
        markRead: MarkNotificationReadUseCase,
        markAllRead: MarkAllNotificationsReadUseCase
    ) {
        self.observeNotifications = observeNotifications
        self.refreshNotifications = refreshNotifications
        self.markReadUseCase = markRead
        self.markAllReadUseCase = markAllRead
    }

    var unreadCount: Int { notifications.filter { !$0.isRead }.count }

    func observe() async {
        for await notifications in observeNotifications() {
            self.notifications = notifications
            recomputeState()
        }
    }

    func loadIfNeeded() async {
        guard !didLoad else { return }
        didLoad = true
        await refresh()
    }

    func refresh() async {
        if notifications.isEmpty { state = .loading }
        do {
            try await refreshNotifications()
            hasCompletedFirstLoad = true
            recomputeState()
        } catch {
            hasCompletedFirstLoad = true
            if notifications.isEmpty {
                state = .error((error as? AppError)?.message ?? AppError.unknown.message)
            }
        }
    }

    func markRead(_ notification: AppNotification) {
        guard !notification.isRead else { return }
        markReadUseCase(id: notification.id)
    }

    func markAllRead() {
        markAllReadUseCase()
    }

    private func recomputeState() {
        if !notifications.isEmpty {
            state = .loaded(notifications)
        } else if hasCompletedFirstLoad {
            state = .empty
        } else {
            state = .loading
        }
    }
}
