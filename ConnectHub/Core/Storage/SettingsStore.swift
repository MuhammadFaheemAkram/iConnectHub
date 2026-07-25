//
//  SettingsStore.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// User-facing appearance preference. Backed by a raw string so it persists
/// cleanly in `UserDefaults`.
enum AppAppearance: String, CaseIterable, Identifiable, Sendable {
    case system, light, dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    /// The `ColorScheme` to force, or `nil` to follow the system.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

/// A display-language preference. Cosmetic in this demo (stored, not applied),
/// to show a persisted picker in Settings.
enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case english, spanish, french, german

    var id: String { rawValue }

    var label: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        }
    }
}

/// Holds simple app preferences behind an observable facade so views never read
/// `UserDefaults` directly: appearance (drives the root color scheme),
/// notifications toggle, and language.
@MainActor
@Observable
final class SettingsStore {
    var appearance: AppAppearance {
        didSet { defaults.set(appearance.rawValue, forKey: appearanceKey) }
    }

    var notificationsEnabled: Bool {
        didSet { defaults.set(notificationsEnabled, forKey: notificationsKey) }
    }

    var language: AppLanguage {
        didSet { defaults.set(language.rawValue, forKey: languageKey) }
    }

    var colorScheme: ColorScheme? { appearance.colorScheme }

    private let defaults: UserDefaults
    private let appearanceKey = "connecthub.appearance"
    private let notificationsKey = "connecthub.notificationsEnabled"
    private let languageKey = "connecthub.language"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let appearanceRaw = defaults.string(forKey: appearanceKey) ?? AppAppearance.system.rawValue
        self.appearance = AppAppearance(rawValue: appearanceRaw) ?? .system
        self.notificationsEnabled = (defaults.object(forKey: notificationsKey) as? Bool) ?? true
        let languageRaw = defaults.string(forKey: languageKey) ?? AppLanguage.english.rawValue
        self.language = AppLanguage(rawValue: languageRaw) ?? .english
    }
}
