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
