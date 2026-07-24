//
//  LogoutUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Clears the persisted session, returning the app to the auth flow.
@MainActor
struct LogoutUseCase {
    let sessionRepository: SessionRepository

    func callAsFunction() {
        sessionRepository.clear()
    }
}
