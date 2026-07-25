//
//  RefreshNotificationsUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Loads notifications from the API.
@MainActor
struct RefreshNotificationsUseCase {
    let repository: NotificationRepository
    func callAsFunction() async throws { try await repository.refresh() }
}
