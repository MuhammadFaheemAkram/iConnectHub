//
//  PostCard.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Feed post card: author, relative time, content, optional image, and a footer
/// of like / comment / bookmark actions. Tapping the content area opens the
/// post; the footer buttons handle their own taps.
struct PostCard: View {
    let post: Post
    var onLike: () -> Void = {}
    var onBookmark: () -> Void = {}
    var onComment: () -> Void = {}
    var onOpen: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: CHSpacing.md) {
            Button(action: onOpen) {
                VStack(alignment: .leading, spacing: CHSpacing.md) {
                    header
                    Text(post.content)
                        .font(CHTypography.body)
                        .foregroundStyle(CHColor.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    if let imageURL = post.imageURL {
                        postImage(imageURL)
                    }
                }
            }
            .buttonStyle(.plain)

            footer
        }
        .padding(CHSpacing.lg)
        .background(CHColor.surface, in: RoundedRectangle(cornerRadius: CHRadius.lg, style: .continuous))
    }

    private var header: some View {
        HStack(spacing: CHSpacing.md) {
            CHAvatar(url: post.author.avatarURL, name: post.author.name, size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(post.author.name)
                    .font(CHTypography.headline)
                    .foregroundStyle(CHColor.textPrimary)
                Text(RelativeTime.string(from: post.createdAt))
                    .font(CHTypography.caption)
                    .foregroundStyle(CHColor.textSecondary)
            }
            Spacer(minLength: 0)
        }
    }

    private func postImage(_ url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            case .failure:
                Rectangle().fill(CHColor.groupedBackground)
                    .overlay(Image(systemName: "photo").foregroundStyle(CHColor.textSecondary))
            default:
                Rectangle().fill(CHColor.groupedBackground)
                    .overlay(ProgressView())
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: CHRadius.md, style: .continuous))
    }

    private var footer: some View {
        HStack(spacing: CHSpacing.xl) {
            Button(action: onLike) {
                actionLabel(
                    systemImage: post.isLiked ? "heart.fill" : "heart",
                    count: post.likeCount,
                    tint: post.isLiked ? CHColor.like : CHColor.textSecondary
                )
            }
            .buttonStyle(.plain)

            Button(action: onComment) {
                actionLabel(systemImage: "bubble.right", count: post.commentCount,
                            tint: CHColor.textSecondary)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Button(action: onBookmark) {
                Image(systemName: post.isBookmarked ? "bookmark.fill" : "bookmark")
                    .foregroundStyle(post.isBookmarked ? CHColor.brand : CHColor.textSecondary)
            }
            .buttonStyle(.plain)
        }
        .font(CHTypography.subheadline)
    }

    private func actionLabel(systemImage: String, count: Int, tint: Color) -> some View {
        HStack(spacing: CHSpacing.xs) {
            Image(systemName: systemImage)
            Text(count.formatted(.number.notation(.compactName)))
        }
        .foregroundStyle(tint)
        .contentTransition(.numericText())
    }
}

#Preview {
    let author = User(id: "u", name: "Ada Lovelace", avatarURL: nil,
                      bio: "", followersCount: 0, followingCount: 0)
    return ScrollView {
        VStack(spacing: CHSpacing.md) {
            PostCard(post: Post(id: "1", author: author,
                                content: "Just shipped the analytical engine scheduler! 🎉",
                                imageURL: nil, createdAt: Date().addingTimeInterval(-3600),
                                likeCount: 142, commentCount: 18,
                                isLiked: true, isBookmarked: false))
            PostCard(post: Post(id: "2", author: author,
                                content: "A shorter note.", imageURL: nil,
                                createdAt: Date().addingTimeInterval(-86400),
                                likeCount: 1290, commentCount: 156,
                                isLiked: false, isBookmarked: true))
        }
        .padding()
    }
}
