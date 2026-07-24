//
//  PostDetailView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Full post view: the post card with like/bookmark, a comments preview, and an
/// inline add-comment bar. Observes the cached post so actions stay in sync with
/// the feed.
struct PostDetailView: View {
    @Environment(Router.self) private var router
    @State private var model: PostDetailViewModel

    init(environment: AppEnvironment, postId: String) {
        _model = State(initialValue: environment.makePostDetailViewModel(postId: postId))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CHSpacing.lg) {
                if let post = model.post {
                    PostCard(
                        post: post,
                        onLike: { model.toggleLike() },
                        onBookmark: { model.toggleBookmark() },
                        onComment: { router.push(.comments(postId: post.id)) },
                        onOpen: {}
                    )
                    commentsSection(post: post)
                } else if model.isLoading {
                    CHLoadingState().frame(minHeight: 320)
                } else {
                    CHErrorState(message: model.errorMessage ?? AppError.notFound.message) {
                        Task { await model.load() }
                    }
                    .frame(minHeight: 320)
                }
            }
            .padding(CHSpacing.lg)
        }
        .background(CHColor.groupedBackground)
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { addCommentBar }
        .task { await model.observePostStream() }
        .task { await model.observeCommentsStream() }
        .task { await model.load() }
    }

    private func commentsSection(post: Post) -> some View {
        VStack(alignment: .leading, spacing: CHSpacing.md) {
            HStack {
                Text("Comments")
                    .font(CHTypography.headline)
                Spacer()
                if !model.comments.isEmpty {
                    Button("See all") { router.push(.comments(postId: post.id)) }
                        .font(CHTypography.subheadline)
                }
            }

            if model.comments.isEmpty {
                Text("No comments yet. Start the conversation.")
                    .font(CHTypography.subheadline)
                    .foregroundStyle(CHColor.textSecondary)
                    .padding(.vertical, CHSpacing.sm)
            } else {
                ForEach(model.comments.prefix(3)) { comment in
                    CommentRow(comment: comment)
                }
                if model.comments.count > 3 {
                    Button("View all \(model.comments.count) comments") {
                        router.push(.comments(postId: post.id))
                    }
                    .font(CHTypography.subheadline)
                    .padding(.top, CHSpacing.xs)
                }
            }
        }
        .padding(CHSpacing.lg)
        .background(CHColor.surface, in: RoundedRectangle(cornerRadius: CHRadius.lg, style: .continuous))
    }

    private var addCommentBar: some View {
        @Bindable var model = model
        return HStack(spacing: CHSpacing.sm) {
            TextField("Add a comment…", text: $model.commentInput, axis: .vertical)
                .lineLimit(1...4)
                .padding(CHSpacing.sm)
                .background(CHColor.surface, in: RoundedRectangle(cornerRadius: CHRadius.md, style: .continuous))
            Button {
                Task { await model.sendComment() }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(canSend ? CHColor.brand : CHColor.textSecondary)
            }
            .disabled(!canSend || model.isSendingComment)
        }
        .padding(CHSpacing.md)
        .background(.bar)
    }

    private var canSend: Bool {
        !model.commentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
