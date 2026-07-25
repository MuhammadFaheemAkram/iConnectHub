//
//  MessageBubble.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// A chat message bubble, aligned and tinted by whether the message is mine.
struct MessageBubble: View {
    let message: Message

    var body: some View {
        HStack {
            if message.isMine { Spacer(minLength: 48) }
            Text(message.text)
                .font(CHTypography.body)
                .foregroundStyle(message.isMine ? Color.white : CHColor.textPrimary)
                .padding(.horizontal, CHSpacing.md)
                .padding(.vertical, CHSpacing.sm + 2)
                .background(
                    message.isMine ? CHColor.brand : CHColor.surface,
                    in: RoundedRectangle(cornerRadius: CHRadius.lg, style: .continuous)
                )
            if !message.isMine { Spacer(minLength: 48) }
        }
    }
}

#Preview {
    VStack(spacing: CHSpacing.sm) {
        MessageBubble(message: Message(id: "1", conversationId: "c", senderId: "them",
                                       text: "Hey! Did you get a chance to look at the PR?",
                                       createdAt: Date(), isMine: false))
        MessageBubble(message: Message(id: "2", conversationId: "c", senderId: "me",
                                       text: "Just finished — looks great!",
                                       createdAt: Date(), isMine: true))
    }
    .padding()
}
