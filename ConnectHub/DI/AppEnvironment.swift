//
//  AppEnvironment.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI
import SwiftData

/// Composition root for the app.
///
/// A single object assembles the shared stores, fake services, repositories,
/// and use cases, and is injected into SwiftUI via `@Environment`. Views resolve
/// exactly the dependencies they need instead of reaching for singletons, which
/// keeps the graph explicit and testable.
///
/// Each phase extends this root with the collaborators it introduces:
/// Phase 2 added authentication; Phase 3 adds the SwiftData container and feed.
@MainActor
@Observable
final class AppEnvironment {
    // Persistence
    let modelContainer: ModelContainer

    // Stores
    let sessionStore: SessionStore
    let settingsStore: SettingsStore

    // Auth graph
    let authService: AuthService
    let authRepository: AuthRepository
    let sessionRepository: SessionRepository

    // Feed graph
    let feedService: FeedService
    let feedRepository: FeedRepository

    // Auth use cases
    let loginUseCase: LoginUseCase
    let signUpUseCase: SignUpUseCase
    let logoutUseCase: LogoutUseCase
    let observeSessionUseCase: ObserveSessionUseCase

    init(
        modelContainer: ModelContainer,
        sessionStore: SessionStore,
        settingsStore: SettingsStore,
        authService: AuthService,
        authRepository: AuthRepository,
        sessionRepository: SessionRepository,
        feedService: FeedService,
        feedRepository: FeedRepository
    ) {
        self.modelContainer = modelContainer
        self.sessionStore = sessionStore
        self.settingsStore = settingsStore
        self.authService = authService
        self.authRepository = authRepository
        self.sessionRepository = sessionRepository
        self.feedService = feedService
        self.feedRepository = feedRepository
        self.loginUseCase = LoginUseCase(authRepository: authRepository, sessionRepository: sessionRepository)
        self.signUpUseCase = SignUpUseCase(authRepository: authRepository, sessionRepository: sessionRepository)
        self.logoutUseCase = LogoutUseCase(sessionRepository: sessionRepository)
        self.observeSessionUseCase = ObserveSessionUseCase(sessionRepository: sessionRepository)
    }

    /// The production graph used by the running app.
    static func live() -> AppEnvironment {
        let modelContainer = PersistenceController.makeContainer()
        let sessionStore = SessionStore()
        let authService = FakeAuthService()
        let feedService = FakeFeedService()
        return AppEnvironment(
            modelContainer: modelContainer,
            sessionStore: sessionStore,
            settingsStore: SettingsStore(),
            authService: authService,
            authRepository: DefaultAuthRepository(service: authService),
            sessionRepository: DefaultSessionRepository(store: sessionStore),
            feedService: feedService,
            feedRepository: DefaultFeedRepository(service: feedService, container: modelContainer)
        )
    }

    /// Builds the root view model that drives auth/main routing.
    func makeRootViewModel() -> RootViewModel {
        RootViewModel(sessionRepository: sessionRepository, observeSession: observeSessionUseCase)
    }

    /// Builds a feed view model wired to the shared feed repository.
    func makeFeedViewModel() -> FeedViewModel {
        FeedViewModel(
            observeFeed: ObserveFeedUseCase(repository: feedRepository),
            refreshFeed: RefreshFeedUseCase(repository: feedRepository),
            likePost: LikePostUseCase(repository: feedRepository),
            bookmarkPost: BookmarkPostUseCase(repository: feedRepository)
        )
    }
}
