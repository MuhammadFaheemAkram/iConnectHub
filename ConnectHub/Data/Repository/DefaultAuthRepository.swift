//
//  DefaultAuthRepository.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Default `AuthRepository`: delegates to the `AuthService` and maps its DTOs
/// into domain models. Stateless and `Sendable`.
struct DefaultAuthRepository: AuthRepository {
    let service: AuthService

    func login(email: String, password: String) async throws -> AuthResult {
        let dto = try await service.login(email: email, password: password)
        return AuthMapper.map(dto)
    }

    func signUp(name: String, email: String, password: String) async throws -> AuthResult {
        let dto = try await service.signUp(name: name, email: email, password: password)
        return AuthMapper.map(dto)
    }
}
