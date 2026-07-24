//
//  CHTextField.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Labeled text field with optional secure entry and inline error text.
/// Used across auth, create-post, edit-profile and search screens.
struct CHTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var systemImage: String? = nil
    var isSecure: Bool = false
    var error: String? = nil
    var keyboard: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        VStack(alignment: .leading, spacing: CHSpacing.xs) {
            Text(title)
                .font(CHTypography.captionStrong)
                .foregroundStyle(CHColor.textSecondary)

            HStack(spacing: CHSpacing.sm) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .foregroundStyle(CHColor.textSecondary)
                        .frame(width: 20)
                }
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .textInputAutocapitalization(autocapitalization)
                .keyboardType(keyboard)
                .textContentType(textContentType)
                .autocorrectionDisabled(isSecure || keyboard == .emailAddress)
            }
            .padding(CHSpacing.md)
            .background(CHColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: CHRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: CHRadius.md, style: .continuous)
                    .strokeBorder(error == nil ? .clear : CHColor.like, lineWidth: 1)
            )

            if let error {
                Text(error)
                    .font(CHTypography.caption)
                    .foregroundStyle(CHColor.like)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: error)
    }
}

#Preview {
    @Previewable @State var email = ""
    @Previewable @State var password = "secret"
    return VStack(spacing: CHSpacing.lg) {
        CHTextField(title: "Email", text: $email, placeholder: "you@example.com",
                    systemImage: "envelope", keyboard: .emailAddress)
        CHTextField(title: "Password", text: $password, systemImage: "lock",
                    isSecure: true, error: "Password is too short")
    }
    .padding()
}
