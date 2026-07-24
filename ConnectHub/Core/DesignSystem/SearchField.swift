//
//  SearchField.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Rounded search bar with a leading magnifier and a trailing clear button.
struct SearchField: View {
    @Binding var text: String
    var placeholder: String = "Search users and posts"
    var onSubmit: () -> Void = {}

    var body: some View {
        HStack(spacing: CHSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(CHColor.textSecondary)
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit(onSubmit)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(CHColor.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, CHSpacing.md)
        .padding(.vertical, CHSpacing.sm + 2)
        .background(CHColor.surface, in: Capsule())
    }
}

#Preview {
    @Previewable @State var text = ""
    return SearchField(text: $text).padding()
}
