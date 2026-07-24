//
//  FeedService.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Paging configuration shared by the fake service and the feed view model.
enum FeedPaging {
    static let pageSize = 6
}

/// Service boundary for the feed. `FakeFeedService` backs it with bundled JSON;
/// a real client could replace it behind this protocol.
protocol FeedService: Sendable {
    func feed(page: Int) async throws -> [PostDTO]
    func postDetails(id: String) async throws -> PostDTO
}
