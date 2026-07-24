//
//  RelativeTime.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Formats dates as short relative strings ("3h ago", "2d ago"). `now` is
/// injectable so the formatting is deterministic in tests.
enum RelativeTime {
    private static let formatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    static func string(from date: Date, relativeTo now: Date = Date()) -> String {
        // Avoid "in 0 seconds" for just-created content.
        if abs(date.timeIntervalSince(now)) < 5 { return "now" }
        return formatter.localizedString(for: date, relativeTo: now)
    }
}
