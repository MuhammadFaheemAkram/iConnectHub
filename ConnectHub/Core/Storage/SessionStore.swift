//
//  SessionStore.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// The signed-in user's session. In this demo the token is a locally generated
/// string; Phase 2 formalizes fake auth and persists it the same way a real
/// Keychain-backed token would be.
struct Session: Codable, Equatable, Sendable {
    let userId: String
    let displayName: String
    let email: String
    let token: String
}

/// Single source of truth for authentication state. `RootView` observes
/// `isAuthenticated` to switch between the auth flow and the main app.
///
/// Persistence uses `UserDefaults` for the demo; the store is the only place
/// that touches it, so swapping in a Keychain wrapper later is a one-file change.
@MainActor
@Observable
final class SessionStore {
    private(set) var current: Session?

    var isAuthenticated: Bool { current != nil }

    private let defaults: UserDefaults
    private let storageKey = "connecthub.session"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// Reads any persisted session on launch. The small delay simulates the
    /// asynchronous session check a real app performs behind its splash screen.
    func restore() async {
        try? await Task.sleep(for: .milliseconds(600))
        if let data = defaults.data(forKey: storageKey),
           let session = try? JSONDecoder().decode(Session.self, from: data) {
            current = session
        }
    }

    func signIn(_ session: Session) {
        current = session
        persist()
    }

    func signOut() {
        current = nil
        defaults.removeObject(forKey: storageKey)
    }

    private func persist() {
        guard let current, let data = try? JSONEncoder().encode(current) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
