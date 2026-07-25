//
//  ChatDetailView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// A single conversation: message bubbles, an animated typing indicator while a
/// reply is generated, and an input bar. Messages come from the actor-backed
/// store; sending triggers a simulated reply.
struct ChatDetailView: View {
    @State private var model: ChatDetailViewModel

    init(environment: AppEnvironment, conversationId: String) {
        _model = State(initialValue: environment.makeChatDetailViewModel(conversationId: conversationId))
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: CHSpacing.sm) {
                    ForEach(model.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                    if model.isTyping {
                        TypingIndicator()
                            .id("typing")
                    }
                    Color.clear.frame(height: 1).id(bottomID)
                }
                .padding(CHSpacing.lg)
            }
            .onChange(of: model.messages.count) { scrollToBottom(proxy) }
            .onChange(of: model.isTyping) { scrollToBottom(proxy) }
            .task { await model.load(); scrollToBottom(proxy, animated: false) }
        }
        .background(CHColor.groupedBackground)
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { inputBar }
        .task { await model.observeMessagesStream() }
        .task { await model.observeTypingStream() }
        .task { await model.observeTitle() }
    }

    private let bottomID = "chat-bottom"

    private func scrollToBottom(_ proxy: ScrollViewProxy, animated: Bool = true) {
        if animated {
            withAnimation(.easeOut(duration: 0.2)) { proxy.scrollTo(bottomID, anchor: .bottom) }
        } else {
            proxy.scrollTo(bottomID, anchor: .bottom)
        }
    }

    private var inputBar: some View {
        @Bindable var model = model
        return HStack(spacing: CHSpacing.sm) {
            TextField("Message…", text: $model.input, axis: .vertical)
                .lineLimit(1...4)
                .padding(CHSpacing.sm)
                .background(CHColor.surface, in: RoundedRectangle(cornerRadius: CHRadius.md, style: .continuous))
            Button {
                Task { await model.send() }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(model.canSend ? CHColor.brand : CHColor.textSecondary)
            }
            .disabled(!model.canSend)
        }
        .padding(CHSpacing.md)
        .background(.bar)
    }
}
