//
//  ObserveNotificationsUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Streams the activity notifications.
@MainActor
struct ObserveNotificationsUseCase {
    let repository: NotificationRepository
    func callAsFunction() -> AsyncStream<[AppNotification]> { repository.notificationsStream() }
}
