//
//  AuthValidatorTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
@testable import ConnectHub

@MainActor
struct AuthValidatorTests {

    @Test("Valid emails pass", arguments: [
        "ada@example.com",
        "grace.hopper@navy.mil",
        "a+tag@sub.domain.io"
    ])
    func validEmails(_ email: String) {
        #expect(AuthValidator.validateEmail(email) == nil)
    }

    @Test("Invalid emails fail", arguments: [
        "",
        "   ",
        "nope",
        "missing@tld",
        "@example.com",
        "spaces in@email.com"
    ])
    func invalidEmails(_ email: String) {
        #expect(AuthValidator.validateEmail(email) != nil)
    }

    @Test func passwordMustBeAtLeastSixCharacters() {
        #expect(AuthValidator.validatePassword("") != nil)
        #expect(AuthValidator.validatePassword("12345") != nil)
        #expect(AuthValidator.validatePassword("123456") == nil)
        #expect(AuthValidator.validatePassword("a strong password") == nil)
    }

    @Test func nameMustNotBeBlankAndAtLeastTwoCharacters() {
        #expect(AuthValidator.validateName("") != nil)
        #expect(AuthValidator.validateName("  ") != nil)
        #expect(AuthValidator.validateName("A") != nil)
        #expect(AuthValidator.validateName("Ada") == nil)
    }

    @Test func confirmPasswordMustMatch() {
        #expect(AuthValidator.validateConfirmPassword("secret1", "") != nil)
        #expect(AuthValidator.validateConfirmPassword("secret1", "secret2") != nil)
        #expect(AuthValidator.validateConfirmPassword("secret1", "secret1") == nil)
    }
}
