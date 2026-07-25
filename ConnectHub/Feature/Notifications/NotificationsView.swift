//
//  NotificationsView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Activity tab: the notification list with unread styling, tap-to-read, and a
/// "Mark all read" action.
struct NotificationsView: View {
    @State private var model: NotificationsViewModel

    init(environment: AppEnvironment) {
        _model = State(initialValue: environment.makeNotificationsViewModel())
    }

    var body: some View {
        content
            .background(CHColor.groupedBackground)
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if model.unreadCount > 0 {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Mark all read") { model.markAllRead() }
                            .font(CHTypography.subheadline)
                    }
                }
            }
            .task { await model.observe() }
            .task { await model.loadIfNeeded() }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .loading:
            CHLoadingState()
        case .empty:
            CHEmptyState(systemImage: "bell",
                         title: "No activity yet",
                         message: "Likes, comments, follows, and mentions will appear here.")
        case .error(let message):
            CHErrorState(message: message) { Task { await model.refresh() } }
        case .loaded(let notifications):
            List {
                ForEach(notifications) { notification in
                    Button {
                        model.markRead(notification)
                    } label: {
                        NotificationRow(notification: notification)
                    }
                    .listRowInsets(EdgeInsets(top: CHSpacing.xs, leading: CHSpacing.lg,
                                              bottom: CHSpacing.xs, trailing: CHSpacing.lg))
                    .listRowBackground(notification.isRead ? Color.clear : CHColor.brand.opacity(0.06))
                }
            }
            .listStyle(.plain)
            .refreshable { await model.refresh() }
        }
    }
}
