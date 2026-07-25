//
//  SettingsView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Settings, pushed from the Profile toolbar: appearance, notifications toggle,
/// language, clear cache, log out, and About. Preferences bind directly to
/// `SettingsStore`; actions go through `SettingsViewModel`.
struct SettingsView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var model: SettingsViewModel
    @State private var showClearCacheConfirm = false

    init(environment: AppEnvironment) {
        _model = State(initialValue: environment.makeSettingsViewModel())
    }

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

            Section("Notifications") {
                Toggle("Push Notifications", isOn: $settings.notificationsEnabled)
            }

            Section("Language") {
                Picker("Language", selection: $settings.language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.label).tag(language)
                    }
                }
            }

            Section {
                Button("Clear Cache") { showClearCacheConfirm = true }
                if model.didClearCache {
                    Text("Cache cleared.")
                        .font(CHTypography.caption)
                        .foregroundStyle(CHColor.success)
                }
            } footer: {
                Text("Removes cached posts and comments. They'll re-download on refresh.")
            }

            Section {
                Button("Log Out", role: .destructive) { model.logoutTapped() }
            }

            Section("About") {
                LabeledContent("Version", value: Self.appVersion)
                LabeledContent("Made by", value: "BitFuse")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Clear cached posts and comments?",
                            isPresented: $showClearCacheConfirm, titleVisibility: .visible) {
            Button("Clear Cache", role: .destructive) { model.clearCacheTapped() }
            Button("Cancel", role: .cancel) {}
        }
    }

    private static var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return "\(version)"
    }
}
