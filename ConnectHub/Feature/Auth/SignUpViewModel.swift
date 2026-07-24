//
//  SignUpViewModel.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Drives the Sign Up screen: form state, per-field validation, and the
/// `SignUpUseCase` call.
@MainActor
@Observable
final class SignUpViewModel {
    var name = ""
    var email = ""
    var password = ""
    var confirmPassword = ""

    private(set) var nameError: String?
    private(set) var emailError: String?
    private(set) var passwordError: String?
    private(set) var confirmError: String?
    private(set) var generalError: String?
    private(set) var isLoading = false

    private let signUp: SignUpUseCase

    init(signUp: SignUpUseCase) {
        self.signUp = signUp
    }

    func createAccount() async {
        nameError = AuthValidator.validateName(name)
        emailError = AuthValidator.validateEmail(email)
        passwordError = AuthValidator.validatePassword(password)
        confirmError = AuthValidator.validateConfirmPassword(password, confirmPassword)
        generalError = nil
        guard nameError == nil, emailError == nil,
              passwordError == nil, confirmError == nil else { return }

        isLoading = true
        defer { isLoading = false }
        do {
            try await signUp(name: name, email: email, password: password)
        } catch let error as AppError {
            generalError = error.message
        } catch {
            generalError = AppError.unknown.message
        }
    }
}
