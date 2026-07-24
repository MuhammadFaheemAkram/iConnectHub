//
//  PlaceholderScreen.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Temporary scaffold used by feature screens that are wired into navigation
/// during Phase 1 but implemented in a later phase. Each screen states which
/// phase brings it to life so the app shell is fully navigable today.
struct PlaceholderScreen: View {
    let systemImage: String
    let title: String
    let phase: String

    var body: some View {
        VStack(spacing: CHSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 52))
                .foregroundStyle(CHColor.brand)
            Text(title)
                .font(CHTypography.largeTitle)
            Text(phase)
                .font(CHTypography.subheadline)
                .foregroundStyle(CHColor.textSecondary)
                .padding(.horizontal, CHSpacing.md)
                .padding(.vertical, CHSpacing.xs)
                .background(CHColor.surface, in: Capsule())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(CHColor.groupedBackground)
    }
}

#Preview {
    PlaceholderScreen(systemImage: "house", title: "Feed",
                      phase: "Coming in Phase 3")
}
