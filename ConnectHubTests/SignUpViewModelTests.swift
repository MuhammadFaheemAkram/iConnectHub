//
//  SignUpViewModelTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
@testable import ConnectHub

@MainActor
struct SignUpViewModelTests {

    private func makeViewModel(
        outcome: StubAuthRepository.Outcome,
        sessionRepository: DefaultSessionRepository
    ) -> SignUpViewModel {
        let signUp = SignUpUseCase(
            authRepository: StubAuthRepository(outcome: outcome),
            sessionRepository: sessionRepository
        )
        return SignUpViewModel(signUp: signUp)
    }

    @Test func mismatchedPasswordsBlockSubmission() async {
        let sessionRepo = makeEphemeralSessionRepository()
        let model = makeViewModel(outcome: .success(.sample()), sessionRepository: sessionRepo)
        model.name = "Ada"
        model.email = "ada@example.com"
        model.password = "secret1"
        model.confirmPassword = "secret2"

        await model.createAccount()

        #expect(model.confirmError != nil)
        #expect(sessionRepo.current == nil)
    }

    @Test func blankNameShowsNameError() async {
        let sessionRepo = makeEphemeralSessionRepository()
        let model = makeViewModel(outcome: .success(.sample()), sessionRepository: sessionRepo)
        model.name = ""
        model.email = "ada@example.com"
        model.password = "secret1"
        model.confirmPassword = "secret1"

        await model.createAccount()

        #expect(model.nameError != nil)
        #expect(sessionRepo.current == nil)
    }

    @Test func validSignUpSavesSession() async {
        let sessionRepo = makeEphemeralSessionRepository()
        let model = makeViewModel(
            outcome: .success(.sample(id: "new1", token: "tk")),
            sessionRepository: sessionRepo
        )
        model.name = "Ada Lovelace"
        model.email = "ada@example.com"
        model.password = "secret1"
        model.confirmPassword = "secret1"

        await model.createAccount()

        #expect(model.nameError == nil)
        #expect(model.emailError == nil)
        #expect(model.passwordError == nil)
        #expect(model.confirmError == nil)
        #expect(model.generalError == nil)
        #expect(sessionRepo.current?.userId == "new1")
        #expect(sessionRepo.current?.email == "ada@example.com")
    }
}
