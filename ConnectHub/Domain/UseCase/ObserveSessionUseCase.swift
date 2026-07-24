//
//  ObserveSessionUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Streams session changes so the root view can route between the auth flow and
/// the main app as the user signs in and out.
@MainActor
struct ObserveSessionUseCase {
    let sessionRepository: SessionRepository

    func callAsFunction() -> AsyncStream<Session?> {
        sessionRepository.sessions()
    }
}
