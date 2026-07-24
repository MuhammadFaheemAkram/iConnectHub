//
//  Router.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Centralized navigation state for the authenticated app.
///
/// Each tab owns an independent typed path (`[MainRoute]`) so switching tabs
/// preserves each stack, and any screen can push by resolving the binding for
/// the currently selected tab. Sheets that aren't tab-scoped (Create Post) are
/// modeled as separate presentation state.
@MainActor
@Observable
final class Router {
    var selectedTab: MainTab = .feed

    var feedPath: [MainRoute] = []
    var searchPath: [MainRoute] = []
    var bookmarksPath: [MainRoute] = []
    var notificationsPath: [MainRoute] = []
    var profilePath: [MainRoute] = []

    /// Set to present the Create Post sheet from anywhere.
    var isPresentingCreatePost = false

    /// Pushes onto the currently selected tab's stack.
    func push(_ route: MainRoute) {
        switch selectedTab {
        case .feed: feedPath.append(route)
        case .search: searchPath.append(route)
        case .bookmarks: bookmarksPath.append(route)
        case .notifications: notificationsPath.append(route)
        case .profile: profilePath.append(route)
        }
    }

    /// Clears the selected tab's stack back to its root.
    func popToRoot() {
        switch selectedTab {
        case .feed: feedPath.removeAll()
        case .search: searchPath.removeAll()
        case .bookmarks: bookmarksPath.removeAll()
        case .notifications: notificationsPath.removeAll()
        case .profile: profilePath.removeAll()
        }
    }

    /// Binding to the path for a given tab, used by each `NavigationStack`.
    func path(for tab: MainTab) -> Binding<[MainRoute]> {
        switch tab {
        case .feed: return Binding(get: { self.feedPath }, set: { self.feedPath = $0 })
        case .search: return Binding(get: { self.searchPath }, set: { self.searchPath = $0 })
        case .bookmarks: return Binding(get: { self.bookmarksPath }, set: { self.bookmarksPath = $0 })
        case .notifications: return Binding(get: { self.notificationsPath }, set: { self.notificationsPath = $0 })
        case .profile: return Binding(get: { self.profilePath }, set: { self.profilePath = $0 })
        }
    }
}
