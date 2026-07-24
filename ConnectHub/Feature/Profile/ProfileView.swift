//
//  ProfileView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Profile screen. As the Profile tab root it shows the signed-in user's
/// editable profile (Edit Profile, Settings, Log Out); pushed with a `userId`
/// it shows another user read-only. Either way it lists that user's posts.
struct ProfileView: View {
    @Environment(Router.self) private var router
    @Environment(AppEnvironment.self) private var environment
    @State private var model: ProfileViewModel
    @State private var isEditingProfile = false

    init(environment: AppEnvironment, userId: String? = nil) {
        _model = State(initialValue: environment.makeProfileViewModel(userId: userId))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: CHSpacing.lg) {
                if let profile = model.profile {
                    header(profile)
                    if model.isOwnProfile {
                        actions
                    }
                    postsSection
                } else {
                    CHLoadingState().frame(minHeight: 320)
                }
            }
            .padding(CHSpacing.lg)
        }
        .background(CHColor.groupedBackground)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if model.isOwnProfile {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { router.push(.settings) } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
        }
        .sheet(isPresented: $isEditingProfile) {
            EditProfileView(environment: environment)
        }
        .task { await model.observeProfileStream() }
        .task { await model.observeFeedStream() }
    }

    private func header(_ profile: User) -> some View {
        VStack(spacing: CHSpacing.md) {
            CHAvatar(url: profile.avatarURL, name: profile.name, size: 96)
            VStack(spacing: CHSpacing.xs) {
                Text(profile.name)
                    .font(CHTypography.largeTitle)
                if !profile.bio.isEmpty {
                    Text(profile.bio)
                        .font(CHTypography.subheadline)
                        .foregroundStyle(CHColor.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            HStack(spacing: CHSpacing.xl) {
                stat(profile.followersCount, "Followers")
                stat(profile.followingCount, "Following")
                stat(model.userPosts.count, "Posts")
            }
            .padding(.top, CHSpacing.xs)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CHSpacing.lg)
    }

    private func stat(_ value: Int, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value.formatted(.number.notation(.compactName)))
                .font(CHTypography.title)
            Text(label)
                .font(CHTypography.caption)
                .foregroundStyle(CHColor.textSecondary)
        }
    }

    private var actions: some View {
        HStack(spacing: CHSpacing.md) {
            CHButton(title: "Edit Profile", systemImage: "pencil", style: .secondary) {
                isEditingProfile = true
            }
            CHButton(title: "Log Out", style: .tertiary) {
                model.performLogout()
            }
        }
    }

    @ViewBuilder
    private var postsSection: some View {
        VStack(alignment: .leading, spacing: CHSpacing.md) {
            Text("Posts")
                .font(CHTypography.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            if model.userPosts.isEmpty {
                Text(model.isOwnProfile
                     ? "You haven't posted yet. Tap the compose button on the feed to share something."
                     : "No posts yet.")
                    .font(CHTypography.subheadline)
                    .foregroundStyle(CHColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, CHSpacing.sm)
            } else {
                ForEach(model.userPosts) { post in
                    PostCard(
                        post: post,
                        onOpen: { router.push(.postDetail(id: post.id)) },
                        onAuthor: { }
                    )
                }
            }
        }
    }
}
