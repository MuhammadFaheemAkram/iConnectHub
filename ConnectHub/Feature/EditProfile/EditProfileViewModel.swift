//
//  EditProfileViewModel.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Drives Edit Profile: prefilled from the current profile, validates name and
/// avatar URL, and persists via `UpdateProfileUseCase`.
@MainActor
@Observable
final class EditProfileViewModel {
    var name: String
    var bio: String
    var avatarURL: String

    private(set) var nameError: String?
    private(set) var avatarURLError: String?

    let bioLimit = 160
    var bioCount: Int { bio.count }
    var isBioOverLimit: Bool { bio.count > bioLimit }

    private let updateProfile: UpdateProfileUseCase

    init(profile: User, updateProfile: UpdateProfileUseCase) {
        self.updateProfile = updateProfile
        self.name = profile.name
        self.bio = profile.bio
        self.avatarURL = profile.avatarURL?.absoluteString ?? ""
    }

    /// Returns `true` when saved, so the view can dismiss.
    func save() -> Bool {
        nameError = AuthValidator.validateName(name)
        avatarURLError = PostValidator.validateImageURL(avatarURL)
        guard nameError == nil, avatarURLError == nil, !isBioOverLimit else { return false }

        let trimmedURL = avatarURL.trimmingCharacters(in: .whitespaces)
        let url = trimmedURL.isEmpty ? nil : URL(string: trimmedURL)
        updateProfile(
            name: name.trimmingCharacters(in: .whitespaces),
            bio: bio.trimmingCharacters(in: .whitespacesAndNewlines),
            avatarURL: url
        )
        return true
    }
}
