//
//  AuthService.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Retrofit-style service boundary for authentication. The app depends only on
/// this protocol; `FakeAuthService` backs it today and a real `URLSession`
/// implementation could replace it with no changes to callers.
protocol AuthService: Sendable {
    func login(email: String, password: String) async throws -> AuthDTO
    func signUp(name: String, email: String, password: String) async throws -> AuthDTO
}
