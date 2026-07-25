//
//  SettingsViewModel.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Handles the Settings actions (clear cache, log out). Appearance / notifications
/// / language are bound directly to `SettingsStore`.
@MainActor
@Observable
final class SettingsViewModel {
    private(set) var didClearCache = false

    private let clearCache: ClearCacheUseCase
    private let logout: LogoutUseCase

    init(clearCache: ClearCacheUseCase, logout: LogoutUseCase) {
        self.clearCache = clearCache
        self.logout = logout
    }

    func clearCacheTapped() {
        try? clearCache()
        didClearCache = true
    }

    func logoutTapped() {
        logout()
    }
}
