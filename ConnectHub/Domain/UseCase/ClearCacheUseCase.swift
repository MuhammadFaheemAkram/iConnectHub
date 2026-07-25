//
//  ClearCacheUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Clears the offline cache (posts + comments) from Settings.
@MainActor
struct ClearCacheUseCase {
    let feedRepository: FeedRepository
    func callAsFunction() throws { try feedRepository.clearCache() }
}
