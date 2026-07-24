//
//  CHErrorBanner.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Inline error banner for form-level failures (e.g. a rejected login). Distinct
/// from `CHErrorState`, which is a full-screen error placeholder.
struct CHErrorBanner: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: CHSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message)
                .font(CHTypography.subheadline)
            Spacer(minLength: 0)
        }
        .foregroundStyle(CHColor.like)
        .padding(CHSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: CHRadius.md, style: .continuous)
                .fill(CHColor.like.opacity(0.12))
        )
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    CHErrorBanner(message: "Your session has expired. Please sign in again.")
        .padding()
}
