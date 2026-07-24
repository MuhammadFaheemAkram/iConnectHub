//
//  RootView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Top-level view that performs the session check and then routes to either the
/// authentication flow or the main app. This is the seam that keeps the signed
/// in and signed out worlds fully separate.
struct RootView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var didCheckSession = false

    var body: some View {
        content
            .task {
                await environment.sessionStore.restore()
                didCheckSession = true
            }
            .animation(.easeInOut(duration: 0.3), value: didCheckSession)
            .animation(.easeInOut(duration: 0.3), value: environment.sessionStore.isAuthenticated)
            .preferredColorScheme(environment.settingsStore.colorScheme)
    }

    @ViewBuilder
    private var content: some View {
        if !didCheckSession {
            SplashView()
                .transition(.opacity)
        } else if environment.sessionStore.isAuthenticated {
            MainFlowView()
                .transition(.opacity)
        } else {
            AuthFlowView()
                .transition(.opacity)
        }
    }
}
