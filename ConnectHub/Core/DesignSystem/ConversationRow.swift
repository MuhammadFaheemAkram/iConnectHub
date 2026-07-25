//
//  ConversationRow.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// A row in the chat list: participant, last message, time, and unread badge.
struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: CHSpacing.md) {
            CHAvatar(url: conversation.participant.avatarURL,
                     name: conversation.participant.name, size: 52)
            VStack(alignment: .leading, spacing: CHSpacing.xxs) {
                HStack {
                    Text(conversation.participant.name)
                        .font(CHTypography.headline)
                        .foregroundStyle(CHColor.textPrimary)
                    Spacer()
                    Text(RelativeTime.string(from: conversation.updatedAt))
                        .font(CHTypography.caption)
                        .foregroundStyle(CHColor.textSecondary)
                }
                HStack(spacing: CHSpacing.sm) {
                    Text(conversation.lastMessage)
                        .font(CHTypography.subheadline)
                        .foregroundStyle(conversation.unreadCount > 0 ? CHColor.textPrimary : CHColor.textSecondary)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(CHTypography.captionStrong)
                            .foregroundStyle(.white)
                            .frame(minWidth: 20, minHeight: 20)
                            .background(CHColor.brand, in: Circle())
                    }
                }
            }
        }
        .padding(.vertical, CHSpacing.xs)
    }
}

#Preview {
    let user = User(id: "u", name: "Grace Hopper", avatarURL: nil, bio: "",
                    followersCount: 0, followingCount: 0)
    return List {
        ConversationRow(conversation: Conversation(id: "1", participant: user,
            lastMessage: "Approved with 12 comments, as tradition demands.",
            unreadCount: 2, updatedAt: Date().addingTimeInterval(-600)))
        ConversationRow(conversation: Conversation(id: "2", participant: user,
            lastMessage: "Sounds good!", unreadCount: 0,
            updatedAt: Date().addingTimeInterval(-7200)))
    }
    .listStyle(.plain)
}
