//
//  LoginViewModelTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
@testable import ConnectHub

@MainActor
struct LoginViewModelTests {

    private func makeViewModel(
        outcome: StubAuthRepository.Outcome,
        sessionRepository: DefaultSessionRepository
    ) -> LoginViewModel {
        let login = LoginUseCase(
            authRepository: StubAuthRepository(outcome: outcome),
            sessionRepository: sessionRepository
        )
        return LoginViewModel(login: login)
    }

    @Test func invalidInputShowsValidationErrorsAndSkipsLogin() async {
        let sessionRepo = makeEphemeralSessionRepository()
        let model = makeViewModel(outcome: .success(.sample()), sessionRepository: sessionRepo)
        model.email = "not-an-email"
        model.password = "123" // too short

        await model.signIn()

        #expect(model.emailError != nil)
        #expect(model.passwordError != nil)
        #expect(model.generalError == nil)
        #expect(sessionRepo.current == nil) // use case never ran
        #expect(model.isLoading == false)
    }

    @Test func successfulLoginSavesSessionFromInput() async {
        let sessionRepo = makeEphemeralSessionRepository()
        let model = makeViewModel(
            outcome: .success(.sample(id: "u42", token: "abc")),
            sessionRepository: sessionRepo
        )
        model.email = "ada@example.com"
        model.password = "secret1"

        await model.signIn()

        #expect(model.emailError == nil)
        #expect(model.passwordError == nil)
        #expect(model.generalError == nil)
        #expect(model.isLoading == false)
        #expect(sessionRepo.current?.userId == "u42")
        #expect(sessionRepo.current?.token == "abc")
        // The email is taken from the form input, not the fake profile.
        #expect(sessionRepo.current?.email == "ada@example.com")
    }

    @Test func failedLoginSurfacesErrorAndKeepsSessionEmpty() async {
        let sessionRepo = makeEphemeralSessionRepository()
        let model = makeViewModel(outcome: .failure(.unauthorized), sessionRepository: sessionRepo)
        model.email = "ada@example.com"
        model.password = "secret1"

        await model.signIn()

        #expect(model.generalError == AppError.unauthorized.message)
        #expect(sessionRepo.current == nil)
        #expect(model.isLoading == false)
    }
}
