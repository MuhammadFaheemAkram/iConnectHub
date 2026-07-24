//
//  AuthFlowView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Hosts the unauthenticated experience. Login is the stack root; Sign Up is
/// pushed on top via a type-safe `AuthRoute`.
struct AuthFlowView: View {
    @State private var path: [AuthRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            LoginView(path: $path)
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .signUp:
                        SignUpView(path: $path)
                    }
                }
        }
    }
}
