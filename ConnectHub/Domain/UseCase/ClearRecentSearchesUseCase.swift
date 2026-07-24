//
//  ClearRecentSearchesUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Clears the user's recent searches.
@MainActor
struct ClearRecentSearchesUseCase {
    let repository: SearchRepository

    func callAsFunction() {
        repository.clearRecentSearches()
    }
}
