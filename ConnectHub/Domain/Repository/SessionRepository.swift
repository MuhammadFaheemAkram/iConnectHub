//
//  SessionRepository.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Domain boundary for the persisted session. Wraps the `SessionStore` so use
/// cases and view models never touch storage directly, and exposes an
/// `AsyncStream` so the root can react to sign-in / sign-out.
///
/// `@MainActor` because it wraps the main-actor session store and vends UI-facing
/// state.
@MainActor
protocol SessionRepository {
    var current: Session? { get }
    func restore() async
    func save(_ session: Session)
    func clear()
    /// Emits the current session immediately, then again on every change.
    func sessions() -> AsyncStream<Session?>
}
