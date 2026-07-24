//
//  ProfileViewModel.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Drives the Profile screen. For the signed-in user it observes the editable
/// profile; for another user it derives the profile from the cached feed. Either
/// way it shows that user's posts (filtered from the feed cache).
@MainActor
@Observable
final class ProfileViewModel {
    let userId: String?
    private(set) var profile: User?
    private(set) var userPosts: [Post] = []

    var isOwnProfile: Bool { userId == nil }

    private var allPosts: [Post] = []

    private let observeProfile: ObserveProfileUseCase
    private let observeFeed: ObserveFeedUseCase
    private let logout: LogoutUseCase

    init(
        userId: String?,
        observeProfile: ObserveProfileUseCase,
        observeFeed: ObserveFeedUseCase,
        logout: LogoutUseCase
    ) {
        self.userId = userId
        self.observeProfile = observeProfile
        self.observeFeed = observeFeed
        self.logout = logout
    }

    func observeProfileStream() async {
        guard isOwnProfile else { return }
        for await user in observeProfile() {
            profile = user
            recompute()
        }
    }

    func observeFeedStream() async {
        for await posts in observeFeed() {
            allPosts = posts
            recompute()
        }
    }

    func performLogout() {
        logout()
    }

    private func recompute() {
        // For another user, derive the profile from a cached post's author.
        if !isOwnProfile, let userId {
            profile = allPosts.first { $0.author.id == userId }?.author ?? profile
        }
        let targetId = profile?.id ?? userId
        userPosts = allPosts.filter { $0.author.id == targetId }
    }
}
