//
//  AuthRoute.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Destinations reachable inside the unauthenticated flow. The login screen is
/// the stack root, so only Sign Up is pushed.
enum AuthRoute: Hashable {
    case signUp
}
