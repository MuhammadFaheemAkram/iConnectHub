//
//  NotificationMapper.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Maps a `NotificationDTO` into the domain `AppNotification`.
enum NotificationMapper {
    static func toDomain(_ dto: NotificationDTO) -> AppNotification {
        AppNotification(
            id: dto.id,
            kind: AppNotification.Kind(rawValue: dto.kind) ?? .like,
            text: dto.text,
            createdAt: dto.createdAt,
            isRead: dto.isRead
        )
    }
}
