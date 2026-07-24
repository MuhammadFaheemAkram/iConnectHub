//
//  RootView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Top-level view. Delegates the routing decision to `RootViewModel`, which
/// restores the session and observes sign-in/out, and renders the splash, auth
/// flow, or main flow accordingly.
struct RootView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var model: RootViewModel?

    var body: some View {
        content
            .task {
                guard model == nil else { return }
                let viewModel = environment.makeRootViewModel()
                model = viewModel
                await viewModel.start()
            }
            .animation(.easeInOut(duration: 0.3), value: model?.phase)
            .preferredColorScheme(environment.settingsStore.colorScheme)
    }

    @ViewBuilder
    private var content: some View {
        switch model?.phase {
        case .authenticated:
            MainFlowView().transition(.opacity)
        case .unauthenticated:
            AuthFlowView().transition(.opacity)
        case .loading, .none:
            SplashView().transition(.opacity)
        }
    }
}
