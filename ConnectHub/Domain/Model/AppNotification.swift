//
//  AppNotification.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// An activity notification. `Kind` categorizes it for iconography and copy.
struct AppNotification: Identifiable, Sendable, Equatable {
    let id: String
    let kind: Kind
    let text: String
    let createdAt: Date
    var isRead: Bool

    enum Kind: String, Sendable {
        case like, comment, follow, mention

        /// SF Symbol used by `NotificationRow`.
        var systemImage: String {
            switch self {
            case .like: return "heart.fill"
            case .comment: return "bubble.right.fill"
            case .follow: return "person.badge.plus.fill"
            case .mention: return "at"
            }
        }
    }
}
