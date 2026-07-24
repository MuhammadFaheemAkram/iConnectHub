//
//  CreatePostView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Create Post, presented as a sheet from the Feed toolbar. Phase 4 adds the
/// text editor, character counter, optional image URL and fake submit that
/// inserts into the local cache.
struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            PlaceholderScreen(systemImage: "square.and.pencil", title: "New Post",
                              phase: "Coming in Phase 4")
                .navigationTitle("New Post")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }
}
