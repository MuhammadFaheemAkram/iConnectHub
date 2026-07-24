//
//  FeedView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Feed tab root. Phase 3 fills this with the offline-first post list; Phase 1
/// establishes the screen and its toolbar entries (Chats and Create Post).
struct FeedView: View {
    @Environment(Router.self) private var router

    var body: some View {
        PlaceholderScreen(systemImage: "house.fill", title: "Feed",
                          phase: "Coming in Phase 3")
            .navigationTitle("ConnectHub")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        router.push(.chatList)
                    } label: {
                        Image(systemName: "bubble.left.and.bubble.right")
                    }
                    .accessibilityLabel("Chats")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        router.isPresentingCreatePost = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .accessibilityLabel("Create Post")
                }
            }
    }
}
