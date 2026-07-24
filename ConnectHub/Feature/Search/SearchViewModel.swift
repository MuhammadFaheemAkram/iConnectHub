//
//  SearchViewModel.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation
import Combine

/// Drives Search. The query is debounced through a Combine pipeline before
/// hitting the (local) search use case; committing a search records it in the
/// persisted recent list.
@MainActor
@Observable
final class SearchViewModel {
    var query = "" {
        didSet { querySubject.send(query) }
    }

    private(set) var results: SearchResults = .empty
    private(set) var isSearching = false
    private(set) var recentSearches: [String] = []

    var hasQuery: Bool {
        !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @ObservationIgnored private let querySubject = PassthroughSubject<String, Never>()
    @ObservationIgnored private var cancellables: Set<AnyCancellable> = []

    private let search: SearchUseCase
    private let observeRecent: ObserveRecentSearchesUseCase
    private let addRecent: AddRecentSearchUseCase
    private let clearRecent: ClearRecentSearchesUseCase

    init(
        search: SearchUseCase,
        observeRecent: ObserveRecentSearchesUseCase,
        addRecent: AddRecentSearchUseCase,
        clearRecent: ClearRecentSearchesUseCase
    ) {
        self.search = search
        self.observeRecent = observeRecent
        self.addRecent = addRecent
        self.clearRecent = clearRecent

        querySubject
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                Task { await self?.performSearch(text) }
            }
            .store(in: &cancellables)
    }

    func observeRecentSearches() async {
        for await recents in observeRecent() {
            recentSearches = recents
        }
    }

    /// Records the current query and runs it immediately (submit / pick recent).
    func submit() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        addRecent(trimmed)
    }

    func selectRecent(_ term: String) {
        query = term
        addRecent(term)
    }

    func clearRecentSearches() {
        clearRecent()
    }

    private func performSearch(_ text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            results = .empty
            isSearching = false
            return
        }
        isSearching = true
        results = await search(query: trimmed)
        isSearching = false
    }
}
