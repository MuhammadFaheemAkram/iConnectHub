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
    @Environment(AppEnvironment.self) private var environment
    @State private var router = Router()

    var body: some View {
        @Bindable var router = router
        TabView(selection: $router.selectedTab) {
            tabStack(.feed) { FeedView(environment: environment) }
            tabStack(.search) { SearchView(environment: environment) }
            tabStack(.bookmarks) { BookmarksView(environment: environment) }
            tabStack(.notifications) { NotificationsView() }
            tabStack(.profile) { ProfileView(environment: environment) }
        }
        .tint(CHColor.brand)
        .environment(router)
        .sheet(isPresented: $router.isPresentingCreatePost) {
            CreatePostView(environment: environment)
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
            PostDetailView(environment: environment, postId: id)
        case .comments(let postId):
            CommentsView(environment: environment, postId: postId)
        case .userProfile(let id):
            ProfileView(environment: environment, userId: id)
        case .chatList:
            ChatListView()
        case .chatDetail(let conversationId):
            ChatDetailView(conversationId: conversationId)
        case .settings:
            SettingsView()
        }
    }
}
