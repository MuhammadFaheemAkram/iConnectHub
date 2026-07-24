//
//  CHButton.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Primary reusable button. Supports visual styles and an inline loading
/// spinner so callers never wire up their own `ProgressView` overlay.
struct CHButton: View {
    enum Style {
        case primary
        case secondary
        case tertiary
    }

    let title: String
    var systemImage: String? = nil
    var style: Style = .primary
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CHSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(foreground)
                } else if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(CHTypography.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, CHSpacing.md)
            .foregroundStyle(foreground)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: CHRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: CHRadius.md, style: .continuous)
                    .strokeBorder(CHColor.brand, lineWidth: style == .secondary ? 1 : 0)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1 : 0.5)
    }

    private var foreground: Color {
        switch style {
        case .primary: return .white
        case .secondary, .tertiary: return CHColor.brand
        }
    }

    private var background: Color {
        switch style {
        case .primary: return CHColor.brand
        case .secondary: return .clear
        case .tertiary: return CHColor.brand.opacity(0.12)
        }
    }
}

#Preview {
    VStack(spacing: CHSpacing.lg) {
        CHButton(title: "Primary", systemImage: "checkmark") {}
        CHButton(title: "Secondary", style: .secondary) {}
        CHButton(title: "Tertiary", style: .tertiary) {}
        CHButton(title: "Loading", isLoading: true) {}
        CHButton(title: "Disabled", isEnabled: false) {}
    }
    .padding()
}
