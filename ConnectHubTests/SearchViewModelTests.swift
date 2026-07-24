//
//  SearchViewModelTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
@testable import ConnectHub

@MainActor
struct SearchViewModelTests {

    private func makeViewModel(_ repo: StubSearchRepository) -> SearchViewModel {
        SearchViewModel(
            search: SearchUseCase(repository: repo),
            observeRecent: ObserveRecentSearchesUseCase(repository: repo),
            addRecent: AddRecentSearchUseCase(repository: repo),
            clearRecent: ClearRecentSearchesUseCase(repository: repo)
        )
    }

    @Test func submitRecordsTrimmedRecentSearch() {
        let repo = StubSearchRepository()
        let model = makeViewModel(repo)
        model.query = "  swiftui  "
        model.submit()
        #expect(repo.addedRecents == ["swiftui"])
    }

    @Test func submitIgnoresBlankQuery() {
        let repo = StubSearchRepository()
        let model = makeViewModel(repo)
        model.query = "   "
        model.submit()
        #expect(repo.addedRecents.isEmpty)
    }

    @Test func selectRecentSetsQueryAndRecordsIt() {
        let repo = StubSearchRepository()
        let model = makeViewModel(repo)
        model.selectRecent("ada")
        #expect(model.query == "ada")
        #expect(repo.addedRecents == ["ada"])
    }

    @Test func clearRecentSearchesForwardsToRepository() {
        let repo = StubSearchRepository()
        let model = makeViewModel(repo)
        model.clearRecentSearches()
        #expect(repo.clearCalled)
    }
}
