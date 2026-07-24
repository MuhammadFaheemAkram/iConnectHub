//
//  CommentsView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Full comments screen for a post: list with swipe-to-delete on own comments,
/// loading/empty/error states, and an add-comment bar.
struct CommentsView: View {
    @State private var model: CommentsViewModel

    init(environment: AppEnvironment, postId: String) {
        _model = State(initialValue: environment.makeCommentsViewModel(postId: postId))
    }

    var body: some View {
        content
            .background(CHColor.groupedBackground)
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) { addCommentBar }
            .task { await model.observe() }
            .task { await model.loadIfNeeded() }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .loading:
            CHLoadingState(message: "Loading comments…")
        case .empty:
            CHEmptyState(systemImage: "bubble.left.and.text.bubble.right",
                         title: "No comments yet",
                         message: "Be the first to comment.")
        case .error(let message):
            CHErrorState(message: message) { Task { await model.refresh() } }
        case .loaded(let comments):
            List {
                ForEach(comments) { comment in
                    CommentRow(comment: comment)
                        .listRowInsets(EdgeInsets(top: CHSpacing.xs, leading: CHSpacing.lg,
                                                  bottom: CHSpacing.xs, trailing: CHSpacing.lg))
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing) {
                            if comment.isOwnComment {
                                Button(role: .destructive) {
                                    model.delete(comment)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                }
            }
            .listStyle(.plain)
            .refreshable { await model.refresh() }
        }
    }

    private var addCommentBar: some View {
        @Bindable var model = model
        return HStack(spacing: CHSpacing.sm) {
            TextField("Add a comment…", text: $model.input, axis: .vertical)
                .lineLimit(1...4)
                .padding(CHSpacing.sm)
                .background(CHColor.surface, in: RoundedRectangle(cornerRadius: CHRadius.md, style: .continuous))
            Button {
                Task { await model.send() }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(canSend ? CHColor.brand : CHColor.textSecondary)
            }
            .disabled(!canSend || model.isSending)
        }
        .padding(CHSpacing.md)
        .background(.bar)
    }

    private var canSend: Bool {
        !model.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
