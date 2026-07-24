//
//  AddRecentSearchUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Records a committed search term in the recent searches list.
@MainActor
struct AddRecentSearchUseCase {
    let repository: SearchRepository

    func callAsFunction(_ query: String) {
        repository.addRecentSearch(query)
    }
}
