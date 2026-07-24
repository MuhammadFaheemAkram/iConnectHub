//
//  PostDetailView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Full post view, pushed from the feed. Phase 4 renders the post, like/bookmark
/// actions and a comments preview.
struct PostDetailView: View {
    let postId: String

    var body: some View {
        PlaceholderScreen(systemImage: "doc.text.image", title: "Post",
                          phase: "Coming in Phase 4")
            .navigationTitle("Post")
            .navigationBarTitleDisplayMode(.inline)
    }
}
