//
//  MarkNotificationReadUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Marks a single notification read.
@MainActor
struct MarkNotificationReadUseCase {
    let repository: NotificationRepository
    func callAsFunction(id: String) { repository.markRead(id: id) }
}
