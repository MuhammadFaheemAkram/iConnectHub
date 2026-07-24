//
//  MainRoute.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// The five root tabs of the authenticated app.
enum MainTab: Hashable, CaseIterable, Identifiable {
    case feed, search, bookmarks, notifications, profile

    var id: Self { self }

    var title: String {
        switch self {
        case .feed: return "Feed"
        case .search: return "Search"
        case .bookmarks: return "Bookmarks"
        case .notifications: return "Activity"
        case .profile: return "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .feed: return "house"
        case .search: return "magnifyingglass"
        case .bookmarks: return "bookmark"
        case .notifications: return "bell"
        case .profile: return "person.crop.circle"
        }
    }
}

/// Type-safe push destinations shared across the main tab stacks. Detail
/// screens are always pushed (or presented), never used as a tab root.
enum MainRoute: Hashable {
    case postDetail(id: String)
    case comments(postId: String)
    case userProfile(id: String)
    case chatList
    case chatDetail(conversationId: String)
    case settings
}
