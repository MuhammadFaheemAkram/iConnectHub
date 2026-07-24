//
//  ChatListView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Conversation list, pushed from the Feed toolbar. Phase 6 adds conversations,
/// unread counts and navigation into a chat.
struct ChatListView: View {
    var body: some View {
        PlaceholderScreen(systemImage: "bubble.left.and.bubble.right.fill",
                          title: "Chats", phase: "Coming in Phase 6")
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.inline)
    }
}
