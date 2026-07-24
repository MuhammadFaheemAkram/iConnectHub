//
//  ChatDetailView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// A single conversation. Phase 6 adds message bubbles, sending, the simulated
/// reply and typing indicator backed by an actor message store.
struct ChatDetailView: View {
    let conversationId: String

    var body: some View {
        PlaceholderScreen(systemImage: "bubble.left.fill", title: "Chat",
                          phase: "Coming in Phase 6")
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
    }
}
