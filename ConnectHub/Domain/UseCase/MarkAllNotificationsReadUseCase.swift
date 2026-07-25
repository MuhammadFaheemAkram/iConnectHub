//
//  MarkAllNotificationsReadUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Marks every notification read.
@MainActor
struct MarkAllNotificationsReadUseCase {
    let repository: NotificationRepository
    func callAsFunction() { repository.markAllRead() }
}
