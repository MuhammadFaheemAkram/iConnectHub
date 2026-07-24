//
//  SearchView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Search tab: a debounced search over cached users and posts, with a persisted
/// recent-searches list shown when the query is empty.
struct SearchView: View {
    @Environment(Router.self) private var router
    @State private var model: SearchViewModel

    init(environment: AppEnvironment) {
        _model = State(initialValue: environment.makeSearchViewModel())
    }

    var body: some View {
        @Bindable var model = model
        VStack(spacing: CHSpacing.md) {
            SearchField(text: $model.query, onSubmit: { model.submit() })
                .padding(.horizontal, CHSpacing.lg)
                .padding(.top, CHSpacing.sm)
            content
        }
        .background(CHColor.groupedBackground)
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .task { await model.observeRecentSearches() }
    }

    @ViewBuilder
    private var content: some View {
        if model.hasQuery {
            results
        } else {
            recents
        }
    }

    @ViewBuilder
    private var recents: some View {
        if model.recentSearches.isEmpty {
            CHEmptyState(systemImage: "magnifyingglass",
                         title: "Search ConnectHub",
                         message: "Find people and posts by name or keyword.")
        } else {
            List {
                Section {
                    ForEach(model.recentSearches, id: \.self) { term in
                        Button { model.selectRecent(term) } label: {
                            Label(term, systemImage: "clock.arrow.circlepath")
                                .foregroundStyle(CHColor.textPrimary)
                        }
                    }
                } header: {
                    HStack {
                        Text("Recent")
                        Spacer()
                        Button("Clear") { model.clearRecentSearches() }
                            .font(CHTypography.captionStrong)
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    @ViewBuilder
    private var results: some View {
        if model.results.isEmpty && !model.isSearching {
            CHEmptyState(systemImage: "questionmark.circle",
                         title: "No results",
                         message: "Try a different name or keyword.")
        } else {
            List {
                if !model.results.users.isEmpty {
                    Section("People") {
                        ForEach(model.results.users) { user in
                            Button { router.push(.userProfile(id: user.id)) } label: {
                                userRow(user)
                            }
                        }
                    }
                }
                if !model.results.posts.isEmpty {
                    Section("Posts") {
                        ForEach(model.results.posts) { post in
                            Button { router.push(.postDetail(id: post.id)) } label: {
                                postRow(post)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    private func userRow(_ user: User) -> some View {
        HStack(spacing: CHSpacing.md) {
            CHAvatar(url: user.avatarURL, name: user.name, size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .font(CHTypography.headline)
                    .foregroundStyle(CHColor.textPrimary)
                Text("\(user.followersCount.formatted(.number.notation(.compactName))) followers")
                    .font(CHTypography.caption)
                    .foregroundStyle(CHColor.textSecondary)
            }
            Spacer()
        }
    }

    private func postRow(_ post: Post) -> some View {
        VStack(alignment: .leading, spacing: CHSpacing.xs) {
            Text(post.author.name)
                .font(CHTypography.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(CHColor.textPrimary)
            Text(post.content)
                .font(CHTypography.subheadline)
                .foregroundStyle(CHColor.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
    }
}
