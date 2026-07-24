//
//  User.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Core domain model for a person on ConnectHub. A plain, `Sendable` value type
/// with no dependency on transport (DTO) or persistence (`@Model`) concerns —
/// mappers translate into it at the layer boundary. `Codable` so the current
/// user's profile can be persisted directly.
struct User: Identifiable, Sendable, Equatable, Codable {
    let id: String
    var name: String
    var avatarURL: URL?
    var bio: String
    var followersCount: Int
    var followingCount: Int
}
