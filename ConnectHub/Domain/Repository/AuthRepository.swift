//
//  AuthRepository.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Domain boundary for authentication. Hides the service + mapping details;
/// use cases depend on this, never on `AuthService` or DTOs directly.
protocol AuthRepository: Sendable {
    func login(email: String, password: String) async throws -> AuthResult
    func signUp(name: String, email: String, password: String) async throws -> AuthResult
}
