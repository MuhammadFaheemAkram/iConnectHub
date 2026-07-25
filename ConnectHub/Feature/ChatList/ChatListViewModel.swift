//
//  ChatListViewModel.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Drives the chat list: observes conversations, refreshes from the API, and
/// filters by a search query.
@MainActor
@Observable
final class ChatListViewModel {
    enum State: Equatable {
        case loading
        case empty
        case loaded
        case error(String)
    }

    private(set) var state: State = .loading
    var searchText = ""

    private(set) var conversations: [Conversation] = []
    private var didLoad = false
    private var hasCompletedFirstLoad = false

    private let observeConversations: ObserveConversationsUseCase
    private let refreshConversations: RefreshConversationsUseCase

    init(observeConversations: ObserveConversationsUseCase, refreshConversations: RefreshConversationsUseCase) {
        self.observeConversations = observeConversations
        self.refreshConversations = refreshConversations
    }

    var filteredConversations: [Conversation] {
        let needle = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !needle.isEmpty else { return conversations }
        return conversations.filter {
            $0.participant.name.lowercased().contains(needle) || $0.lastMessage.lowercased().contains(needle)
        }
    }

    func observe() async {
        for await conversations in observeConversations() {
            self.conversations = conversations
            recomputeState()
        }
    }

    func loadIfNeeded() async {
        guard !didLoad else { return }
        didLoad = true
        await refresh()
    }

    func refresh() async {
        if conversations.isEmpty { state = .loading }
        do {
            try await refreshConversations()
            hasCompletedFirstLoad = true
            recomputeState()
        } catch {
            hasCompletedFirstLoad = true
            if conversations.isEmpty {
                state = .error((error as? AppError)?.message ?? AppError.unknown.message)
            }
        }
    }

    private func recomputeState() {
        if !conversations.isEmpty {
            state = .loaded
        } else if hasCompletedFirstLoad {
            state = .empty
        } else {
            state = .loading
        }
    }
}
