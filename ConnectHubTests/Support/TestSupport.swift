//
//  TestSupport.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation
@testable import ConnectHub

// MARK: - Test doubles

/// Configurable `AuthRepository` fake for view-model and use-case tests.
struct StubAuthRepository: AuthRepository {
    enum Outcome: Sendable {
        case success(AuthResult)
        case failure(AppError)
    }

    let outcome: Outcome

    func login(email: String, password: String) async throws -> AuthResult {
        try resolve()
    }

    func signUp(name: String, email: String, password: String) async throws -> AuthResult {
        try resolve()
    }

    private func resolve() throws -> AuthResult {
        switch outcome {
        case .success(let result): return result
        case .failure(let error): throw error
        }
    }
}

// MARK: - Sample factories

extension User {
    static func sample(id: String = "u1", name: String = "Ada Lovelace") -> User {
        User(id: id, name: name, avatarURL: nil, bio: "Test bio",
             followersCount: 10, followingCount: 5)
    }
}

extension AuthResult {
    static func sample(id: String = "u1", token: String = "tok") -> AuthResult {
        AuthResult(user: .sample(id: id), token: token)
    }
}

extension Session {
    static func sample(userId: String = "u1", email: String = "ada@example.com") -> Session {
        Session(userId: userId, displayName: "Ada", email: email, token: "tok")
    }
}

// MARK: - Helpers

/// A `DefaultSessionRepository` backed by an isolated, ephemeral `UserDefaults`
/// suite so tests never touch (or collide on) real preferences.
@MainActor
func makeEphemeralSessionRepository() -> DefaultSessionRepository {
    let suite = "ConnectHubTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defaults.removePersistentDomain(forName: suite)
    return DefaultSessionRepository(store: SessionStore(defaults: defaults))
}
