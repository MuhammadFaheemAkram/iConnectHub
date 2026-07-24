//
//  UserMapper.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Translates the `UserDTO` wire model into the domain `User`, absorbing
/// transport quirks (optional strings, URL parsing) at the boundary.
enum UserMapper {
    static func map(_ dto: UserDTO) -> User {
        User(
            id: dto.id,
            name: dto.name,
            avatarURL: dto.avatarURL.flatMap(URL.init(string:)),
            bio: dto.bio ?? "",
            followersCount: dto.followersCount,
            followingCount: dto.followingCount
        )
    }
}
