//
//  SignUpView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Account-creation screen backed by `SignUpViewModel`: per-field validation,
/// a loading button, and inline error handling. Success signs the new user in.
struct SignUpView: View {
    @Binding var path: [AuthRoute]
    @State private var model: SignUpViewModel

    init(path: Binding<[AuthRoute]>, signUpUseCase: SignUpUseCase) {
        self._path = path
        self._model = State(initialValue: SignUpViewModel(signUp: signUpUseCase))
    }

    var body: some View {
        @Bindable var model = model
        ScrollView {
            VStack(spacing: CHSpacing.lg) {
                CHTextField(title: "Name", text: $model.name,
                            placeholder: "Your name",
                            systemImage: "person",
                            error: model.nameError,
                            textContentType: .name,
                            autocapitalization: .words)
                CHTextField(title: "Email", text: $model.email,
                            placeholder: "you@example.com",
                            systemImage: "envelope",
                            error: model.emailError,
                            keyboard: .emailAddress,
                            textContentType: .emailAddress,
                            autocapitalization: .never)
                CHTextField(title: "Password", text: $model.password,
                            placeholder: "Create a password",
                            systemImage: "lock",
                            isSecure: true,
                            error: model.passwordError,
                            textContentType: .newPassword)
                CHTextField(title: "Confirm Password", text: $model.confirmPassword,
                            placeholder: "Re-enter your password",
                            systemImage: "lock.rotation",
                            isSecure: true,
                            error: model.confirmError,
                            textContentType: .newPassword)

                if let generalError = model.generalError {
                    CHErrorBanner(message: generalError)
                }

                CHButton(title: "Create Account", systemImage: "person.badge.plus",
                         isLoading: model.isLoading) {
                    Task { await model.createAccount() }
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
}
