//
//  CommentRow.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// A single comment: author avatar, name, relative time, an optional "You" badge
/// for own comments, and the text.
struct CommentRow: View {
    let comment: Comment

    var body: some View {
        HStack(alignment: .top, spacing: CHSpacing.md) {
            CHAvatar(url: comment.author.avatarURL, name: comment.author.name, size: 36)
            VStack(alignment: .leading, spacing: CHSpacing.xs) {
                HStack(spacing: CHSpacing.sm) {
                    Text(comment.author.name)
                        .font(CHTypography.subheadline)
                        .fontWeight(.semibold)
                    if comment.isOwnComment {
                        Text("You")
                            .font(CHTypography.caption)
                            .foregroundStyle(CHColor.brand)
                            .padding(.horizontal, CHSpacing.sm)
                            .padding(.vertical, 1)
                            .background(CHColor.brand.opacity(0.12), in: Capsule())
                    }
                    Text(RelativeTime.string(from: comment.createdAt))
                        .font(CHTypography.caption)
                        .foregroundStyle(CHColor.textSecondary)
                }
                Text(comment.text)
                    .font(CHTypography.body)
                    .foregroundStyle(CHColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, CHSpacing.xs)
    }
}

#Preview {
    let author = User(id: "u", name: "Grace Hopper", avatarURL: nil, bio: "",
                      followersCount: 0, followingCount: 0)
    return VStack(alignment: .leading) {
        CommentRow(comment: Comment(id: "1", postId: "p", author: author,
                                    text: "Naming is the second-hardest problem in computer science.",
                                    createdAt: Date().addingTimeInterval(-1800), isOwnComment: false))
        CommentRow(comment: Comment(id: "2", postId: "p", author: author,
                                    text: "Totally agree!", createdAt: Date(), isOwnComment: true))
    }
    .padding()
}
