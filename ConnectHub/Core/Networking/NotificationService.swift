//
//  NotificationService.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Service boundary for activity notifications.
protocol NotificationService: Sendable {
    func notifications() async throws -> [NotificationDTO]
}
