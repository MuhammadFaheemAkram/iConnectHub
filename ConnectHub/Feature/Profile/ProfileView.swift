//
//  ProfileView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Profile screen. Doubles as the Profile tab root (own profile, `userId == nil`)
/// and a pushed screen for other users. Phase 5 builds out the real profile;
/// Phase 1 wires the Settings entry and a working Log Out.
struct ProfileView: View {
    var userId: String? = nil

    @Environment(Router.self) private var router
    @Environment(AppEnvironment.self) private var environment

    private var isOwnProfile: Bool { userId == nil }

    var body: some View {
        PlaceholderScreen(systemImage: "person.crop.circle.fill",
                          title: isOwnProfile ? "Your Profile" : "Profile",
                          phase: "Coming in Phase 5")
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isOwnProfile {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            router.push(.settings)
                        } label: {
                            Image(systemName: "gearshape")
                        }
                        .accessibilityLabel("Settings")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if isOwnProfile {
                    CHButton(title: "Log Out", style: .secondary) {
                        environment.sessionStore.signOut()
                    }
                    .padding(CHSpacing.lg)
                    .background(.bar)
                }
            }
    }
}
