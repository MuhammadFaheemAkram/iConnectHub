//
//  SettingsView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Settings, pushed from the Profile toolbar. Phase 1 already drives appearance
/// through `SettingsStore`, so the appearance picker is live here; notifications,
/// language, clear cache and About arrive in Phase 6.
struct SettingsView: View {
    @Environment(AppEnvironment.self) private var environment

    var body: some View {
        @Bindable var settings = environment.settingsStore
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $settings.appearance) {
                    ForEach(AppAppearance.allCases) { appearance in
                        Text(appearance.label).tag(appearance)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                LabeledContent("More settings", value: "Phase 6")
                    .foregroundStyle(CHColor.textSecondary)
            } footer: {
                Text("Notifications, language, clear cache, and About arrive in Phase 6.")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
