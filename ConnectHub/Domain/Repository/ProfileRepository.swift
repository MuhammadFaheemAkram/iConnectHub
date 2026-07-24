//
//  ProfileRepository.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// The signed-in user's editable profile, persisted locally and seeded from the
/// session on first use.
@MainActor
protocol ProfileRepository {
    func currentProfile() -> User
    func observeProfile() -> AsyncStream<User>
    func updateProfile(name: String, bio: String, avatarURL: URL?)
}
