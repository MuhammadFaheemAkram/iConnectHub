//
//  AppEnvironment.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Composition root for the app.
///
/// A single object assembles the shared stores (and, from later phases, the
/// fake services, repositories and use cases) and is injected into SwiftUI via
/// `@Environment`. Views resolve exactly the dependencies they need instead of
/// reaching for singletons, which keeps the graph explicit and testable.
///
/// Phase 1 wires the two foundational stores; each subsequent phase extends
/// this root with the collaborators that phase introduces.
@MainActor
@Observable
final class AppEnvironment {
    let sessionStore: SessionStore
    let settingsStore: SettingsStore

    init(sessionStore: SessionStore, settingsStore: SettingsStore) {
        self.sessionStore = sessionStore
        self.settingsStore = settingsStore
    }

    /// The production graph used by the running app.
    static func live() -> AppEnvironment {
        AppEnvironment(
            sessionStore: SessionStore(),
            settingsStore: SettingsStore()
        )
    }
}
