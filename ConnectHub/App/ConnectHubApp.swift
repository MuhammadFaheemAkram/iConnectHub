//
//  ConnectHubApp.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

@main
struct ConnectHubApp: App {
    /// The single composition root, created once and injected into the view tree.
    @State private var environment = AppEnvironment.live()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(environment)
        }
    }
}
