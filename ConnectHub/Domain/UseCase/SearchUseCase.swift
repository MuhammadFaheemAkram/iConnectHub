//
//  SearchUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Runs a local search over cached users and posts.
@MainActor
struct SearchUseCase {
    let repository: SearchRepository

    func callAsFunction(query: String) async -> SearchResults {
        await repository.search(query: query)
    }
}
