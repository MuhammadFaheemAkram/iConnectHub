//
//  CommentMapper.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Translates between the comment DTO, the SwiftData entity, and the domain model.
enum CommentMapper {
    static func makeEntity(from dto: CommentDTO, isOwnComment: Bool) -> CommentEntity {
        CommentEntity(
            id: dto.id,
            postId: dto.postId,
            authorId: dto.author.id,
            authorName: dto.author.name,
            authorAvatarURLString: dto.author.avatarURL,
            text: dto.text,
            createdAt: dto.createdAt,
            isOwnComment: isOwnComment
        )
    }

    static func toDomain(_ entity: CommentEntity) -> Comment {
        Comment(
            id: entity.id,
            postId: entity.postId,
            author: User(
                id: entity.authorId,
                name: entity.authorName,
                avatarURL: entity.authorAvatarURLString.flatMap(URL.init(string:)),
                bio: "",
                followersCount: 0,
                followingCount: 0
            ),
            text: entity.text,
            createdAt: entity.createdAt,
            isOwnComment: entity.isOwnComment
        )
    }
}
