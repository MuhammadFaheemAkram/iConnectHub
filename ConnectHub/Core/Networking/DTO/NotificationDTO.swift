//
//  NotificationDTO.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Wire model for an activity notification. `kind` is a raw string mapped to
/// `AppNotification.Kind` at the boundary.
struct NotificationDTO: Codable, Equatable, Sendable {
    let id: String
    let kind: String
    let text: String
    let createdAt: Date
    let isRead: Bool
}
