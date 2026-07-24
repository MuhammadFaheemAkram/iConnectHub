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

/// Holds simple app preferences behind an observable facade so views never read
/// `UserDefaults` directly. Phase 6 grows this with notification and language
/// settings; Phase 1 only needs appearance to drive the root color scheme.
@MainActor
@Observable
final class SettingsStore {
    var appearance: AppAppearance {
        didSet { defaults.set(appearance.rawValue, forKey: appearanceKey) }
    }

    var colorScheme: ColorScheme? { appearance.colorScheme }

    private let defaults: UserDefaults
    private let appearanceKey = "connecthub.appearance"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let raw = defaults.string(forKey: appearanceKey) ?? AppAppearance.system.rawValue
        self.appearance = AppAppearance(rawValue: raw) ?? .system
    }
}
