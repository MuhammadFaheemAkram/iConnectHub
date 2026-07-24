//
//  MainFlowView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Hosts the authenticated experience: a five-tab `TabView` where every tab is
/// its own `NavigationStack`. The shared `Router` owns per-tab paths and the
/// Create Post sheet, and is injected so any screen can drive navigation.
struct MainFlowView: View {
    @State private var router = Router()

    var body: some View {
        @Bindable var router = router
        TabView(selection: $router.selectedTab) {
            tabStack(.feed) { FeedView() }
            tabStack(.search) { SearchView() }
            tabStack(.bookmarks) { BookmarksView() }
            tabStack(.notifications) { NotificationsView() }
            tabStack(.profile) { ProfileView() }
        }
        .tint(CHColor.brand)
        .environment(router)
        .sheet(isPresented: $router.isPresentingCreatePost) {
            CreatePostView()
        }
    }

    /// Builds a tab: a `NavigationStack` bound to that tab's path, with the
    /// shared destination table and tab-bar item attached.
    private func tabStack(_ tab: MainTab, @ViewBuilder root: () -> some View) -> some View {
        NavigationStack(path: router.path(for: tab)) {
            root()
                .navigationDestination(for: MainRoute.self) { route in
                    destination(for: route)
                }
        }
        .tabItem { Label(tab.title, systemImage: tab.systemImage) }
        .tag(tab)
    }

    /// Central resolution of every pushed `MainRoute` to its screen. Living in
    /// the app layer keeps the Core navigation types free of feature imports.
    @ViewBuilder
    private func destination(for route: MainRoute) -> some View {
        switch route {
        case .postDetail(let id):
            PostDetailView(postId: id)
        case .comments(let postId):
            CommentsView(postId: postId)
        case .userProfile(let id):
            ProfileView(userId: id)
        case .chatList:
            ChatListView()
        case .chatDetail(let conversationId):
            ChatDetailView(conversationId: conversationId)
        case .settings:
            SettingsView()
        }
    }
}
