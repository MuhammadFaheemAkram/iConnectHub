//
//  FakeAuthService.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Fake `AuthService`: serves a bundled demo profile, simulates latency with
/// `Task.sleep`, and offers an error toggle. Structured so a real networking
/// implementation could drop in behind the same protocol.
struct FakeAuthService: AuthService {
    /// Flip to exercise the error path throughout the app.
    private let shouldThrowError = false
    private let latency: Duration = .milliseconds(800)

    func login(email: String, password: String) async throws -> AuthDTO {
        try await Task.sleep(for: latency)
        if shouldThrowError { throw AppError.network }

        // Demo hook: this address always simulates a rejected credential so the
        // error state is easy to see.
        if email.lowercased() == "blocked@connecthub.app" {
            throw AppError.unauthorized
        }

        let profile = Self.seedProfile()
        let user = UserDTO(
            id: profile.id,
            name: profile.name,
            email: email,
            avatarURL: profile.avatarURL,
            bio: profile.bio,
            followersCount: profile.followersCount,
            followingCount: profile.followingCount
        )
        return AuthDTO(token: Self.makeToken(), user: user)
    }

    func signUp(name: String, email: String, password: String) async throws -> AuthDTO {
        try await Task.sleep(for: latency)
        if shouldThrowError { throw AppError.network }

        // A brand-new account starts empty.
        let user = UserDTO(
            id: "u_\(UUID().uuidString.prefix(8))",
            name: name,
            email: email,
            avatarURL: nil,
            bio: "New to ConnectHub 👋",
            followersCount: 0,
            followingCount: 0
        )
        return AuthDTO(token: Self.makeToken(), user: user)
    }

    /// The bundled demo profile, with a safe in-code fallback so the app keeps
    /// working even if the resource is unavailable.
    private static func seedProfile() -> UserDTO {
        (try? BundleJSON.decode(UserDTO.self, from: "auth_user")) ?? fallbackProfile
    }

    private static let fallbackProfile = UserDTO(
        id: "u_demo",
        name: "Demo User",
        email: "demo@connecthub.app",
        avatarURL: "https://i.pravatar.cc/300?img=12",
        bio: "Exploring ConnectHub.",
        followersCount: 128,
        followingCount: 87
    )

    private static func makeToken() -> String {
        "fake.\(UUID().uuidString).token"
    }
}
