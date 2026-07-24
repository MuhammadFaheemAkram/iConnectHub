//
//  CHAvatar.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Circular avatar backed by `AsyncImage`. Falls back to the user's initials
/// on a brand-tinted circle while loading or when no URL is available.
struct CHAvatar: View {
    let url: URL?
    var name: String = ""
    var size: CGFloat = 44

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            default:
                initialsPlaceholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(CHColor.separator, lineWidth: 0.5))
    }

    private var initialsPlaceholder: some View {
        ZStack {
            CHColor.brand.opacity(0.18)
            Text(initials)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(CHColor.brand)
        }
    }

    private var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }.map(String.init).joined()
        return letters.isEmpty ? "?" : letters.uppercased()
    }
}

#Preview {
    HStack(spacing: CHSpacing.lg) {
        CHAvatar(url: nil, name: "Ada Lovelace", size: 64)
        CHAvatar(url: nil, name: "Grace Hopper")
        CHAvatar(url: nil, name: "", size: 32)
    }
    .padding()
}
