//
//  RootViewModel.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Owns the root routing decision. Restores any persisted session behind the
/// splash, then observes the session stream so signing in or out flips the app
/// between the auth flow and the main flow.
@MainActor
@Observable
final class RootViewModel {
    enum Phase: Equatable {
        case loading
        case authenticated
        case unauthenticated
    }

    private(set) var phase: Phase = .loading

    private let sessionRepository: SessionRepository
    private let observeSession: ObserveSessionUseCase

    init(sessionRepository: SessionRepository, observeSession: ObserveSessionUseCase) {
        self.sessionRepository = sessionRepository
        self.observeSession = observeSession
    }

    func start() async {
        await sessionRepository.restore()
        phase = resolvePhase(for: sessionRepository.current)
        for await session in observeSession() {
            phase = resolvePhase(for: session)
        }
    }

    private func resolvePhase(for session: Session?) -> Phase {
        session == nil ? .unauthenticated : .authenticated
    }
}
