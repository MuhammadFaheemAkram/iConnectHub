//
//  CommentsView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Comments for a post. Phase 4 adds the comment list plus add/delete-own-comment.
struct CommentsView: View {
    let postId: String

    var body: some View {
        PlaceholderScreen(systemImage: "text.bubble", title: "Comments",
                          phase: "Coming in Phase 4")
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
    }
}
