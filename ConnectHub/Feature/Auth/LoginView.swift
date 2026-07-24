//
//  LoginView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Sign-in screen. Phase 1 wires up the layout and a fake sign-in that seeds a
/// session so the main app is reachable. Phase 2 replaces the action with real
/// validation, loading/error states and a `LoginUseCase`.
struct LoginView: View {
    @Binding var path: [AuthRoute]
    @Environment(AppEnvironment.self) private var environment

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ScrollView {
            VStack(spacing: CHSpacing.xl) {
                header
                VStack(spacing: CHSpacing.lg) {
                    CHTextField(title: "Email", text: $email,
                                placeholder: "you@example.com",
                                systemImage: "envelope",
                                keyboard: .emailAddress,
                                textContentType: .emailAddress,
                                autocapitalization: .never)
                    CHTextField(title: "Password", text: $password,
                                placeholder: "Your password",
                                systemImage: "lock",
                                isSecure: true,
                                textContentType: .password)
                }
                VStack(spacing: CHSpacing.md) {
                    CHButton(title: "Sign In", systemImage: "arrow.right") {
                        signIn()
                    }
                    Button {
                        path.append(.signUp)
                    } label: {
                        Text("Don't have an account? **Sign Up**")
                            .font(CHTypography.subheadline)
                            .foregroundStyle(CHColor.textSecondary)
                    }
                }
            }
            .padding(CHSpacing.xl)
        }
        .background(CHColor.groupedBackground)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
    }

    private var header: some View {
        VStack(spacing: CHSpacing.sm) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 52))
                .foregroundStyle(CHColor.brand)
            Text("Welcome Back")
                .font(CHTypography.largeTitle)
            Text("Sign in to continue to ConnectHub")
                .font(CHTypography.subheadline)
                .foregroundStyle(CHColor.textSecondary)
        }
        .padding(.top, CHSpacing.xxl)
    }

    /// Phase 1 placeholder: accepts any input and seeds a demo session.
    private func signIn() {
        let session = Session(
            userId: UUID().uuidString,
            displayName: "Demo User",
            email: email.isEmpty ? "demo@connecthub.app" : email,
            token: UUID().uuidString
        )
        environment.sessionStore.signIn(session)
    }
}
