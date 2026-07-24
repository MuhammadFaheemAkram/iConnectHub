//
//  SignUpView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Account creation screen. Phase 1 provides the form and a fake account
/// creation that signs the user straight in; Phase 2 adds field validation and
/// a `SignUpUseCase`.
struct SignUpView: View {
    @Binding var path: [AuthRoute]
    @Environment(AppEnvironment.self) private var environment

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        ScrollView {
            VStack(spacing: CHSpacing.lg) {
                CHTextField(title: "Name", text: $name,
                            placeholder: "Your name",
                            systemImage: "person",
                            textContentType: .name,
                            autocapitalization: .words)
                CHTextField(title: "Email", text: $email,
                            placeholder: "you@example.com",
                            systemImage: "envelope",
                            keyboard: .emailAddress,
                            textContentType: .emailAddress,
                            autocapitalization: .never)
                CHTextField(title: "Password", text: $password,
                            placeholder: "Create a password",
                            systemImage: "lock",
                            isSecure: true,
                            textContentType: .newPassword)
                CHTextField(title: "Confirm Password", text: $confirmPassword,
                            placeholder: "Re-enter your password",
                            systemImage: "lock.rotation",
                            isSecure: true,
                            textContentType: .newPassword)

                CHButton(title: "Create Account", systemImage: "person.badge.plus") {
                    createAccount()
                }
                .padding(.top, CHSpacing.sm)
            }
            .padding(CHSpacing.xl)
        }
        .background(CHColor.groupedBackground)
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
    }

    /// Phase 1 placeholder: seeds a demo session from the entered details.
    private func createAccount() {
        let session = Session(
            userId: UUID().uuidString,
            displayName: name.isEmpty ? "New User" : name,
            email: email.isEmpty ? "new@connecthub.app" : email,
            token: UUID().uuidString
        )
        environment.sessionStore.signIn(session)
    }
}
