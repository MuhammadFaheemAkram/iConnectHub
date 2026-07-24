//
//  FeedState.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Explicit UI states for the feed screen. Every async list in the app models
/// its states this way.
enum FeedState: Equatable {
    case loading
    case empty
    case loaded([Post])
    case error(String)
}
