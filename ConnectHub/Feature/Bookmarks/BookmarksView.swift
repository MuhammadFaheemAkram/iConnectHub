//
//  BookmarksView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Bookmarks tab: the bookmarked posts, read offline-first from the cache. The
/// bookmark button removes a post from the list.
struct BookmarksView: View {
    @Environment(Router.self) private var router
    @State private var model: BookmarksViewModel

    init(environment: AppEnvironment) {
        _model = State(initialValue: environment.makeBookmarksViewModel())
    }

    var body: some View {
        content
            .background(CHColor.groupedBackground)
            .navigationTitle("Bookmarks")
            .navigationBarTitleDisplayMode(.inline)
            .task { await model.observe() }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .loading:
            CHLoadingState()
        case .empty:
            CHEmptyState(systemImage: "bookmark",
                         title: "No bookmarks yet",
                         message: "Tap the bookmark icon on a post to save it here.")
        case .loaded(let posts):
            List {
                ForEach(posts) { post in
                    PostCard(
                        post: post,
                        onLike: { model.toggleLike(post) },
                        onBookmark: { model.removeBookmark(post) },
                        onComment: { router.push(.comments(postId: post.id)) },
                        onOpen: { router.push(.postDetail(id: post.id)) },
                        onAuthor: { router.push(.userProfile(id: post.author.id)) }
                    )
                    .listRowInsets(EdgeInsets(top: CHSpacing.sm, leading: CHSpacing.lg,
                                              bottom: CHSpacing.sm, trailing: CHSpacing.lg))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
        }
    }
}
