//
//  DefaultProfileRepository.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Stores the signed-in user's profile in `UserDefaults`, seeding it from the
/// session the first time it's read. Emits updates via `AsyncStream`.
@MainActor
final class DefaultProfileRepository: ProfileRepository {
    private let sessionRepository: SessionRepository
    private let defaults: UserDefaults
    private let key = "connecthub.profile"
    private var continuations: [UUID: AsyncStream<User>.Continuation] = [:]

    init(sessionRepository: SessionRepository, defaults: UserDefaults = .standard) {
        self.sessionRepository = sessionRepository
        self.defaults = defaults
    }

    func currentProfile() -> User {
        if let stored = loadStored() { return stored }
        let seeded = seededProfile()
        persist(seeded)
        return seeded
    }

    func observeProfile() -> AsyncStream<User> {
        let (stream, continuation) = AsyncStream<User>.makeStream()
        let id = UUID()
        continuations[id] = continuation
        continuation.yield(currentProfile())
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor in self?.continuations[id] = nil }
        }
        return stream
    }

    func updateProfile(name: String, bio: String, avatarURL: URL?) {
        var profile = currentProfile()
        profile.name = name
        profile.bio = bio
        profile.avatarURL = avatarURL
        persist(profile)
        emit(profile)
    }

    private func seededProfile() -> User {
        let session = sessionRepository.current
        return User(
            id: session?.userId ?? "me",
            name: session?.displayName ?? "You",
            avatarURL: nil,
            bio: "iOS developer exploring ConnectHub.",
            followersCount: 128,
            followingCount: 89
        )
    }

    private func loadStored() -> User? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }

    private func persist(_ user: User) {
        guard let data = try? JSONEncoder().encode(user) else { return }
        defaults.set(data, forKey: key)
    }

    private func emit(_ user: User) {
        for continuation in continuations.values { continuation.yield(user) }
    }
}
