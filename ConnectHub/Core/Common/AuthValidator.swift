//
//  AuthValidator.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Pure, side-effect-free validation for the auth forms. Kept separate from the
/// view models so the rules are trivially unit-testable and reused by both
/// Login and Sign Up.
///
/// Each function returns an error message when invalid, or `nil` when valid.
enum AuthValidator {
    static func validateEmail(_ email: String) -> String? {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "Email is required." }
        // Pragmatic email shape: something@something.tld
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        let isValid = trimmed.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
        return isValid ? nil : "Enter a valid email address."
    }

    static func validatePassword(_ password: String) -> String? {
        if password.isEmpty { return "Password is required." }
        if password.count < 6 { return "Password must be at least 6 characters." }
        return nil
    }

    static func validateName(_ name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "Name is required." }
        if trimmed.count < 2 { return "Name must be at least 2 characters." }
        return nil
    }

    static func validateConfirmPassword(_ password: String, _ confirmation: String) -> String? {
        if confirmation.isEmpty { return "Please confirm your password." }
        if password != confirmation { return "Passwords don't match." }
        return nil
    }
}
