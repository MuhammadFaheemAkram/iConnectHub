//
//  SearchResults.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// The outcome of a search over the local cache: matching users and posts.
struct SearchResults: Sendable, Equatable {
    var users: [User]
    var posts: [Post]

    static let empty = SearchResults(users: [], posts: [])

    var isEmpty: Bool { users.isEmpty && posts.isEmpty }
}
