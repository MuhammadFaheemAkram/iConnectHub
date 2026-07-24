//
//  Theme.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Design tokens for ConnectHub.
///
/// All colors, spacing, radii and typography live here so screens never
/// hard-code raw values. Colors are built on top of the system semantic
/// palette so light/dark mode and Dynamic Type work for free.
enum CHColor {
    /// Brand accent — a friendly indigo used for primary actions and links.
    static let brand = Color(
        light: Color(red: 0.30, green: 0.36, blue: 0.90),
        dark: Color(red: 0.51, green: 0.56, blue: 0.98)
    )

    static let background = Color(.systemBackground)
    static let groupedBackground = Color(.systemGroupedBackground)
    static let surface = Color(.secondarySystemBackground)
    static let separator = Color(.separator)

    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary

    static let like = Color(red: 0.92, green: 0.28, blue: 0.36)
    static let success = Color.green
    static let warning = Color.orange
}

enum CHSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

enum CHRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let pill: CGFloat = 999
}

/// Typography maps to system text styles so Dynamic Type keeps working;
/// weights are layered on top for hierarchy.
enum CHTypography {
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title = Font.title2.weight(.semibold)
    static let headline = Font.headline
    static let body = Font.body
    static let callout = Font.callout
    static let subheadline = Font.subheadline
    static let caption = Font.caption
    static let captionStrong = Font.caption.weight(.semibold)
}

extension Color {
    /// Builds a color that resolves to different values in light and dark mode.
    /// `nonisolated` so the `CHColor` tokens can be initialized from any context.
    nonisolated init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
