//
//  AuthDTO.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Wire model returned by `AuthService`. Mirrors the shape a real auth endpoint
/// would send, and is mapped into domain types (`AuthResult`/`User`) before it
/// reaches the rest of the app.
struct AuthDTO: Codable, Equatable, Sendable {
    let token: String
    let user: UserDTO
}

/// Wire model for a user profile.
struct UserDTO: Codable, Equatable, Sendable {
    let id: String
    let name: String
    let email: String
    let avatarURL: String?
    let bio: String?
    let followersCount: Int
    let followingCount: Int
}
