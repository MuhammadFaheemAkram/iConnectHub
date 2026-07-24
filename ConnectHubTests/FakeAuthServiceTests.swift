//
//  FakeAuthServiceTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
@testable import ConnectHub

/// Exercises the fake service through the real repository + mapper, including
/// decoding the bundled JSON profile (the test host is the app bundle).
@MainActor
struct FakeAuthServiceTests {

    @Test func loginReturnsMappedResultWithToken() async throws {
        let repository = DefaultAuthRepository(service: FakeAuthService())

        let result = try await repository.login(email: "ada@example.com", password: "secret1")

        #expect(!result.token.isEmpty)
        #expect(!result.user.id.isEmpty)
        #expect(!result.user.name.isEmpty)
    }

    @Test func signUpStartsWithEmptyFollowerCounts() async throws {
        let repository = DefaultAuthRepository(service: FakeAuthService())

        let result = try await repository.signUp(
            name: "Grace Hopper",
            email: "grace@navy.mil",
            password: "secret1"
        )

        #expect(result.user.name == "Grace Hopper")
        #expect(result.user.followersCount == 0)
        #expect(result.user.followingCount == 0)
    }

    @Test func blockedEmailIsRejected() async {
        let repository = DefaultAuthRepository(service: FakeAuthService())

        await #expect(throws: AppError.unauthorized) {
            try await repository.login(email: "blocked@connecthub.app", password: "secret1")
        }
    }
}
