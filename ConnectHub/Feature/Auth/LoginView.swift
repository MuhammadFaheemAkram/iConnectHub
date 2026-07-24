//
//  LoginView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Sign-in screen backed by `LoginViewModel`: validated fields, a loading
/// button, and inline error handling. Success seeds the session and the root
/// switches to the main app.
struct LoginView: View {
    @Binding var path: [AuthRoute]
    @State private var model: LoginViewModel

    init(path: Binding<[AuthRoute]>, loginUseCase: LoginUseCase) {
        self._path = path
        self._model = State(initialValue: LoginViewModel(login: loginUseCase))
    }

    var body: some View {
        @Bindable var model = model
        ScrollView {
            VStack(spacing: CHSpacing.xl) {
                header

                VStack(spacing: CHSpacing.lg) {
                    CHTextField(title: "Email", text: $model.email,
                                placeholder: "you@example.com",
                                systemImage: "envelope",
                                error: model.emailError,
                                keyboard: .emailAddress,
                                textContentType: .emailAddress,
                                autocapitalization: .never)
                    CHTextField(title: "Password", text: $model.password,
                                placeholder: "Your password",
                                systemImage: "lock",
                                isSecure: true,
                                error: model.passwordError,
                                textContentType: .password)
                }

                if let generalError = model.generalError {
                    CHErrorBanner(message: generalError)
                }

                VStack(spacing: CHSpacing.md) {
                    CHButton(title: "Sign In", systemImage: "arrow.right",
                             isLoading: model.isLoading) {
                        Task { await model.signIn() }
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
}
