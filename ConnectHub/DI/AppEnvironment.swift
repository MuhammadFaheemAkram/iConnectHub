//
//  AppEnvironment.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Composition root for the app.
///
/// A single object assembles the shared stores, fake services, repositories,
/// and use cases, and is injected into SwiftUI via `@Environment`. Views resolve
/// exactly the dependencies they need instead of reaching for singletons, which
/// keeps the graph explicit and testable.
///
/// Each phase extends this root with the collaborators it introduces. Phase 2
/// adds the authentication graph.
@MainActor
@Observable
final class AppEnvironment {
    // Stores
    let sessionStore: SessionStore
    let settingsStore: SettingsStore

    // Auth graph
    let authService: AuthService
    let authRepository: AuthRepository
    let sessionRepository: SessionRepository

    // Use cases
    let loginUseCase: LoginUseCase
    let signUpUseCase: SignUpUseCase
    let logoutUseCase: LogoutUseCase
    let observeSessionUseCase: ObserveSessionUseCase

    init(
        sessionStore: SessionStore,
        settingsStore: SettingsStore,
        authService: AuthService,
        authRepository: AuthRepository,
        sessionRepository: SessionRepository
    ) {
        self.sessionStore = sessionStore
        self.settingsStore = settingsStore
        self.authService = authService
        self.authRepository = authRepository
        self.sessionRepository = sessionRepository
        self.loginUseCase = LoginUseCase(authRepository: authRepository, sessionRepository: sessionRepository)
        self.signUpUseCase = SignUpUseCase(authRepository: authRepository, sessionRepository: sessionRepository)
        self.logoutUseCase = LogoutUseCase(sessionRepository: sessionRepository)
        self.observeSessionUseCase = ObserveSessionUseCase(sessionRepository: sessionRepository)
    }

    /// The production graph used by the running app.
    static func live() -> AppEnvironment {
        let sessionStore = SessionStore()
        let authService = FakeAuthService()
        return AppEnvironment(
            sessionStore: sessionStore,
            settingsStore: SettingsStore(),
            authService: authService,
            authRepository: DefaultAuthRepository(service: authService),
            sessionRepository: DefaultSessionRepository(store: sessionStore)
        )
    }

    /// Builds the root view model that drives auth/main routing.
    func makeRootViewModel() -> RootViewModel {
        RootViewModel(sessionRepository: sessionRepository, observeSession: observeSessionUseCase)
    }
}
