//
//  PostMapper.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Translates between the post DTO, the SwiftData entity, and the domain model.
enum PostMapper {
    /// New cache entity from a freshly fetched DTO. Local state starts clean.
    static func makeEntity(from dto: PostDTO) -> PostEntity {
        PostEntity(
            id: dto.id,
            authorId: dto.author.id,
            authorName: dto.author.name,
            authorAvatarURLString: dto.author.avatarURL,
            authorBio: dto.author.bio ?? "",
            authorFollowersCount: dto.author.followersCount,
            authorFollowingCount: dto.author.followingCount,
            content: dto.content,
            imageURLString: dto.imageURL,
            createdAt: dto.createdAt,
            likeCount: dto.likeCount,
            commentCount: dto.commentCount,
            isLiked: false,
            isBookmarked: false
        )
    }

    static func toDomain(_ entity: PostEntity) -> Post {
        Post(
            id: entity.id,
            author: User(
                id: entity.authorId,
                name: entity.authorName,
                avatarURL: entity.authorAvatarURLString.flatMap(URL.init(string:)),
                bio: entity.authorBio,
                followersCount: entity.authorFollowersCount,
                followingCount: entity.authorFollowingCount
            ),
            content: entity.content,
            imageURL: entity.imageURLString.flatMap(URL.init(string:)),
            createdAt: entity.createdAt,
            likeCount: entity.likeCount,
            commentCount: entity.commentCount,
            isLiked: entity.isLiked,
            isBookmarked: entity.isBookmarked
        )
    }
}
