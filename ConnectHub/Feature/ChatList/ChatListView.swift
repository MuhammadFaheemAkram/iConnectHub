//
//  ChatListView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Conversation list, pushed from the Feed toolbar. Searchable; opening a row
/// pushes the chat and marks it read.
struct ChatListView: View {
    @Environment(Router.self) private var router
    @State private var model: ChatListViewModel

    init(environment: AppEnvironment) {
        _model = State(initialValue: environment.makeChatListViewModel())
    }

    var body: some View {
        @Bindable var model = model
        content
            .background(CHColor.groupedBackground)
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $model.searchText, prompt: "Search conversations")
            .task { await model.observe() }
            .task { await model.loadIfNeeded() }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .loading:
            CHLoadingState()
        case .empty:
            CHEmptyState(systemImage: "bubble.left.and.bubble.right",
                         title: "No conversations",
                         message: "Your chats will show up here.")
        case .error(let message):
            CHErrorState(message: message) { Task { await model.refresh() } }
        case .loaded:
            List {
                ForEach(model.filteredConversations) { conversation in
                    Button {
                        router.push(.chatDetail(conversationId: conversation.id))
                    } label: {
                        ConversationRow(conversation: conversation)
                    }
                    .listRowInsets(EdgeInsets(top: CHSpacing.xs, leading: CHSpacing.lg,
                                              bottom: CHSpacing.xs, trailing: CHSpacing.lg))
                }
            }
            .listStyle(.plain)
            .overlay {
                if model.filteredConversations.isEmpty {
                    ContentUnavailableView.search
                }
            }
        }
    }
}
