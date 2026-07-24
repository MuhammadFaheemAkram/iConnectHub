//
//  Session.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// The signed-in user's session: the identity plus the auth token that proves
/// it. `Codable` so it can be persisted, `Sendable` so it can cross actors.
///
/// In this demo the token is generated locally by the fake service; a real
/// backend would return it and it would live in the Keychain.
struct Session: Codable, Equatable, Sendable {
    let userId: String
    let displayName: String
    let email: String
    let token: String
}

extension Session {
    /// The signed-in user as a domain `User`, used when authoring posts and
    /// comments. Profile details (avatar, bio, counts) are filled in Phase 5.
    var asAuthor: User {
        User(id: userId, name: displayName, avatarURL: nil, bio: "",
             followersCount: 0, followingCount: 0)
    }
}
