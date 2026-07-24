//
//  DefaultSessionRepository.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Default `SessionRepository`, backed by the `SessionStore`. Turns the store's
/// imperative sign-in / sign-out into an observable `AsyncStream` so the root
/// can switch flows reactively.
@MainActor
final class DefaultSessionRepository: SessionRepository {
    private let store: SessionStore
    private var continuations: [UUID: AsyncStream<Session?>.Continuation] = [:]

    init(store: SessionStore) {
        self.store = store
    }

    var current: Session? { store.current }

    func restore() async {
        await store.restore()
        emit()
    }

    func save(_ session: Session) {
        store.signIn(session)
        emit()
    }

    func clear() {
        store.signOut()
        emit()
    }

    func sessions() -> AsyncStream<Session?> {
        let (stream, continuation) = AsyncStream<Session?>.makeStream()
        let id = UUID()
        continuations[id] = continuation
        continuation.yield(store.current)
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor in self?.continuations[id] = nil }
        }
        return stream
    }

    private func emit() {
        let value = store.current
        for continuation in continuations.values {
            continuation.yield(value)
        }
    }
}
