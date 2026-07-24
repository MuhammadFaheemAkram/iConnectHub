//
//  FeedView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Feed tab root. Renders the offline-first post list with like/bookmark,
/// pull-to-refresh, and load-more pagination, plus loading/empty/error states.
/// Toolbar entries open Chats and Create Post.
struct FeedView: View {
    @Environment(Router.self) private var router
    @State private var model: FeedViewModel

    init(environment: AppEnvironment) {
        _model = State(initialValue: environment.makeFeedViewModel())
    }

    var body: some View {
        content
            .background(CHColor.groupedBackground)
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
            .task { await model.refreshIfNeeded() }
            .task { await model.observe() }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .loading:
            CHLoadingState(message: "Loading your feed…")
        case .empty:
            CHEmptyState(systemImage: "square.stack.3d.up",
                         title: "No posts yet",
                         message: "Pull to refresh or check back soon.",
                         actionTitle: "Refresh") {
                Task { await model.refresh() }
            }
        case .error(let message):
            CHErrorState(message: message) {
                Task { await model.refresh() }
            }
        case .loaded(let posts):
            feedList(posts)
        }
    }

    private func feedList(_ posts: [Post]) -> some View {
        List {
            ForEach(posts) { post in
                PostCard(
                    post: post,
                    onLike: { model.toggleLike(post) },
                    onBookmark: { model.toggleBookmark(post) },
                    onComment: { router.push(.comments(postId: post.id)) },
                    onOpen: { router.push(.postDetail(id: post.id)) }
                )
                .listRowInsets(EdgeInsets(top: CHSpacing.sm, leading: CHSpacing.lg,
                                          bottom: CHSpacing.sm, trailing: CHSpacing.lg))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .onAppear {
                    if post.id == posts.last?.id {
                        Task { await model.loadMore() }
                    }
                }
            }

            if model.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .refreshable { await model.refresh() }
    }
}
