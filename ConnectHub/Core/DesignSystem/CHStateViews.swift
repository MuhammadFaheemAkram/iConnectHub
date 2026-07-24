//
//  CHStateViews.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Centered loading indicator with an optional caption. Every async screen
/// renders this for its `.loading` state.
struct CHLoadingState: View {
    var message: String = "Loading…"

    var body: some View {
        VStack(spacing: CHSpacing.md) {
            ProgressView()
                .controlSize(.large)
            Text(message)
                .font(CHTypography.subheadline)
                .foregroundStyle(CHColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}

/// Friendly empty-state used when a list has no content. Optionally shows a
/// call-to-action button.
struct CHEmptyState: View {
    let systemImage: String
    let title: String
    var message: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: CHSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 44))
                .foregroundStyle(CHColor.brand)
            Text(title)
                .font(CHTypography.title)
                .multilineTextAlignment(.center)
            if let message {
                Text(message)
                    .font(CHTypography.subheadline)
                    .foregroundStyle(CHColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
            if let actionTitle, let action {
                CHButton(title: actionTitle, style: .tertiary, action: action)
                    .fixedSize()
                    .padding(.top, CHSpacing.xs)
            }
        }
        .padding(CHSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Error state with a retry affordance, driven by an `AppError` message.
struct CHErrorState: View {
    let message: String
    var retryTitle: String = "Try Again"
    var retry: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: CHSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 44))
                .foregroundStyle(CHColor.warning)
            Text("Something went wrong")
                .font(CHTypography.title)
            Text(message)
                .font(CHTypography.subheadline)
                .foregroundStyle(CHColor.textSecondary)
                .multilineTextAlignment(.center)
            if let retry {
                CHButton(title: retryTitle, style: .secondary, action: retry)
                    .fixedSize()
                    .padding(.top, CHSpacing.xs)
            }
        }
        .padding(CHSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Loading") { CHLoadingState() }

#Preview("Empty") {
    CHEmptyState(systemImage: "tray", title: "Nothing here yet",
                 message: "New posts will show up here.",
                 actionTitle: "Refresh") {}
}

#Preview("Error") {
    CHErrorState(message: AppError.network.message) {}
}
