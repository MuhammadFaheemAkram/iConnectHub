//
//  AuthResult.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// The domain outcome of a successful authentication: the authenticated user
/// and the token to persist. The repository returns this; a use case turns it
/// into a `Session`.
struct AuthResult: Sendable, Equatable {
    let user: User
    let token: String
}
