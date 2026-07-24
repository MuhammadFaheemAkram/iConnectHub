//
//  ObserveRecentSearchesUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Streams the user's recent searches.
@MainActor
struct ObserveRecentSearchesUseCase {
    let repository: SearchRepository

    func callAsFunction() -> AsyncStream<[String]> {
        repository.recentSearchesStream()
    }
}
