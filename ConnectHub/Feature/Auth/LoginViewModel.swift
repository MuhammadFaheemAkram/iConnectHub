//
//  LoginViewModel.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Drives the Login screen: holds form state, runs client-side validation, and
/// invokes `LoginUseCase`. Exposes read-only error/loading state to the view.
@MainActor
@Observable
final class LoginViewModel {
    var email = ""
    var password = ""

    private(set) var emailError: String?
    private(set) var passwordError: String?
    private(set) var generalError: String?
    private(set) var isLoading = false

    private let login: LoginUseCase

    init(login: LoginUseCase) {
        self.login = login
    }

    func signIn() async {
        emailError = AuthValidator.validateEmail(email)
        passwordError = AuthValidator.validatePassword(password)
        generalError = nil
        guard emailError == nil, passwordError == nil else { return }

        isLoading = true
        defer { isLoading = false }
        do {
            try await login(email: email, password: password)
            // Success: the session is saved and the root swaps to the main app.
        } catch let error as AppError {
            generalError = error.message
        } catch {
            generalError = AppError.unknown.message
        }
    }
}
