//
//  NotificationRow.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// A row in the activity list: a kind-colored icon, the text, relative time, and
/// an unread dot. Unread rows are emphasized.
struct NotificationRow: View {
    let notification: AppNotification

    var body: some View {
        HStack(spacing: CHSpacing.md) {
            ZStack {
                Circle().fill(tint.opacity(0.15))
                Image(systemName: notification.kind.systemImage)
                    .foregroundStyle(tint)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: CHSpacing.xxs) {
                Text(notification.text)
                    .font(CHTypography.subheadline)
                    .fontWeight(notification.isRead ? .regular : .semibold)
                    .foregroundStyle(CHColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(RelativeTime.string(from: notification.createdAt))
                    .font(CHTypography.caption)
                    .foregroundStyle(CHColor.textSecondary)
            }

            Spacer(minLength: 0)

            if !notification.isRead {
                Circle().fill(CHColor.brand).frame(width: 9, height: 9)
            }
        }
        .padding(.vertical, CHSpacing.xs)
    }

    private var tint: Color {
        switch notification.kind {
        case .like: return CHColor.like
        case .comment: return CHColor.brand
        case .follow: return CHColor.success
        case .mention: return CHColor.warning
        }
    }
}

#Preview {
    List {
        NotificationRow(notification: AppNotification(id: "1", kind: .like,
            text: "Grace Hopper liked your post.", createdAt: Date().addingTimeInterval(-300), isRead: false))
        NotificationRow(notification: AppNotification(id: "2", kind: .follow,
            text: "Alan Turing started following you.", createdAt: Date().addingTimeInterval(-9000), isRead: true))
    }
    .listStyle(.plain)
}
