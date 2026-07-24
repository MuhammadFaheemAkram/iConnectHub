//
//  UpdateProfileUseCase.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Saves edits to the signed-in user's profile.
@MainActor
struct UpdateProfileUseCase {
    let repository: ProfileRepository

    func callAsFunction(name: String, bio: String, avatarURL: URL?) {
        repository.updateProfile(name: name, bio: bio, avatarURL: avatarURL)
    }
}
