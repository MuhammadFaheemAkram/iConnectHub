//
//  SignUpUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Creates a fake account, then persists the resulting session so the new user
/// lands straight in the app.
@MainActor
struct SignUpUseCase {
    let authRepository: AuthRepository
    let sessionRepository: SessionRepository

    func callAsFunction(name: String, email: String, password: String) async throws {
        let result = try await authRepository.signUp(name: name, email: email, password: password)
        let session = Session(
            userId: result.user.id,
            displayName: result.user.name,
            email: email,
            token: result.token
        )
        sessionRepository.save(session)
    }
}
