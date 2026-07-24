//
//  ObserveProfileUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Streams the signed-in user's profile.
@MainActor
struct ObserveProfileUseCase {
    let repository: ProfileRepository

    func callAsFunction() -> AsyncStream<User> {
        repository.observeProfile()
    }
}
