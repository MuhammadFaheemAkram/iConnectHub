//
//  LoginUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Authenticates with email + password, then persists the resulting session.
/// One intent = one use case, so the view model stays declarative.
@MainActor
struct LoginUseCase {
    let authRepository: AuthRepository
    let sessionRepository: SessionRepository

    func callAsFunction(email: String, password: String) async throws {
        let result = try await authRepository.login(email: email, password: password)
        sessionRepository.save(session(from: result, email: email))
    }

    private func session(from result: AuthResult, email: String) -> Session {
        Session(
            userId: result.user.id,
            displayName: result.user.name,
            email: email,
            token: result.token
        )
    }
}
