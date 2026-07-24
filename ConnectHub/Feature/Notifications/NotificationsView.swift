//
//  NotificationsView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Notifications (Activity) tab root. Phase 6 adds the notification list with
/// read/unread handling.
struct NotificationsView: View {
    var body: some View {
        PlaceholderScreen(systemImage: "bell.fill", title: "Activity",
                          phase: "Coming in Phase 6")
            .navigationTitle("Activity")
    }
}
