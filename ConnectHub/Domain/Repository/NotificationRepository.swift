//
//  NotificationRepository.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Activity notifications boundary. Observed via `AsyncStream`; read state is
/// mutated locally.
@MainActor
protocol NotificationRepository {
    func notificationsStream() -> AsyncStream<[AppNotification]>
    func refresh() async throws
    func markRead(id: String)
    func markAllRead()
}
