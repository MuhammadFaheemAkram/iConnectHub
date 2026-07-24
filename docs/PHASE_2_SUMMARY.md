# Phase 2 — Fake Auth + Session

> How ConnectHub authenticates. This phase turns the Phase 1 placeholder sign-in into a real, layered flow: a fake service, repositories behind protocols, use cases, validated view models, a persisted session, and the app's first test suite.

---

## Phase Goal

Give the app a credible authentication story without a backend, and prove the architecture end-to-end for the first time: **View → ViewModel → UseCase → Repository → Service/Store → back to the View**. Everything here is a template the later feature phases copy — DTO↔domain mapping, protocol-based repositories, `@Observable` view models with explicit loading/error state, and dependency injection through `AppEnvironment`.

It also establishes **testing**: a hosted unit-test target using Swift Testing with protocol fakes, so business logic is verified in isolation.

## What Was Implemented

- **Auth models & DTOs** — domain `User`, `Session`, `AuthResult`; wire `AuthDTO`/`UserDTO`; `AuthMapper`/`UserMapper` translating between them.
- **`FakeAuthService`** — conforms to the `AuthService` protocol, serves a bundled `auth_user.json` profile, simulates latency with `Task.sleep`, has a `shouldThrowError` toggle, and a demo "blocked" email that returns an unauthorized error.
- **Repositories** — `AuthRepository` (domain protocol) + `DefaultAuthRepository` (service + mapper); `SessionRepository` (domain protocol) + `DefaultSessionRepository` wrapping `SessionStore` and exposing an `AsyncStream<Session?>`.
- **Use cases** — `LoginUseCase`, `SignUpUseCase`, `LogoutUseCase`, `ObserveSessionUseCase`.
- **Validation** — `AuthValidator`, pure functions for email/password/name/confirm.
- **View models** — `LoginViewModel` and `SignUpViewModel` (`@Observable`), with per-field errors, a general error, and a loading flag.
- **Screens** — Login and Sign Up rewritten to bind to their view models, showing validation errors, a loading button, and an inline `CHErrorBanner`.
- **Root routing** — `RootViewModel` restores the session behind the splash and observes the session stream, switching between `AuthFlowView` and `MainFlowView`; logout now flows through `LogoutUseCase`.
- **Tests** — a `ConnectHubTests` target with 17 tests across 5 suites (validation, both view models, the session repository incl. its stream, and the fake service through the real repository).

## iOS / Swift Concepts Demonstrated

- **Protocol-based dependency injection** — services/repositories are protocols; fakes swap in for tests. `AppEnvironment` composes the graph.
- **DTO ↔ domain mapping** — `Codable` DTOs decoded from bundled JSON, mapped to plain domain structs; the UI never sees a DTO.
- **`@Observable` view models** with read-only state and intent methods (`signIn()`, `createAccount()`).
- **`async/await` error handling** — typed `AppError` surfaced as `generalError`; `defer` resets the loading flag.
- **`AsyncStream`** — the session repository turns imperative save/clear into an observable stream the root consumes with `for await`.
- **`callAsFunction`** — use cases are invoked like functions (`login(email:password:)`).
- **`UITextContentType` / secure entry** for password fields; client-side validation with a regex.
- **Swift Testing** — `@Test`, `#expect`, parameterized `@Test(arguments:)`, `#expect(throws:)`, `@MainActor` suites, and an in-memory `UserDefaults` suite for isolation.

## Data Flow

```
Login screen (email, password)
  → LoginViewModel.signIn()
      → AuthValidator (client-side) ── invalid ─▶ show field errors, stop
      → LoginUseCase(email, password)
          → AuthRepository.login  → AuthService (fake, bundled JSON + delay)
                                   → AuthMapper: AuthDTO → AuthResult(User, token)
          → build Session(from AuthResult + entered email)
          → SessionRepository.save(session)  → SessionStore persists (UserDefaults)
                                             → AsyncStream emits the new session
  → RootViewModel observes the stream → phase = .authenticated → MainFlowView
```

Logout is the same pipe in reverse: `LogoutUseCase → SessionRepository.clear → stream emits nil → RootViewModel → AuthFlowView`.

## Important Files Added

| File | Purpose |
|------|---------|
| `Domain/Model/User.swift`, `Session.swift`, `AuthResult.swift` | Plain domain value types. |
| `Core/Networking/AuthService.swift` | Service protocol boundary. |
| `Core/Networking/FakeAuthService.swift` | Fake implementation (bundled JSON + latency + error toggle). |
| `Core/Networking/DTO/AuthDTO.swift` | Wire models. |
| `Core/Networking/BundleJSON.swift` | Bundled-JSON decode helper. |
| `Core/Networking/Resources/auth_user.json` | Seed demo profile. |
| `Core/Common/AuthValidator.swift` | Pure validation rules. |
| `Domain/Repository/AuthRepository.swift`, `SessionRepository.swift` | Repository protocols. |
| `Data/Repository/DefaultAuthRepository.swift`, `DefaultSessionRepository.swift` | Implementations. |
| `Data/Mapper/UserMapper.swift`, `AuthMapper.swift` | DTO→domain mappers. |
| `Domain/UseCase/{Login,SignUp,Logout,ObserveSession}UseCase.swift` | One intent each. |
| `Feature/Auth/LoginViewModel.swift`, `SignUpViewModel.swift` | Screen state + logic. |
| `App/RootViewModel.swift` | Session-driven root routing. |
| `Core/DesignSystem/CHErrorBanner.swift` | Inline form error banner. |
| `ConnectHubTests/*` | Swift Testing suites + test support. |

## Important Types Added

| Type | Kind | Responsibility | Layer & why |
|------|------|----------------|-------------|
| `AuthService` / `FakeAuthService` | protocol / struct | Auth transport boundary + fake | Core/Networking — swappable for a real client |
| `AuthDTO`, `UserDTO` | `Codable` structs | Wire models | Core/Networking — transport shape, decoded from JSON |
| `AuthResult`, `User`, `Session` | domain structs | Domain values | Domain/Model — no transport/persistence coupling |
| `AuthRepository` / `SessionRepository` | protocols | Data boundaries for use cases | Domain/Repository — depend on abstractions |
| `DefaultAuthRepository` / `DefaultSessionRepository` | structs/class | Concrete data access + mapping + stream | Data/Repository |
| `LoginUseCase` … `ObserveSessionUseCase` | structs | One business intent each | Domain/UseCase — orchestrate repositories |
| `AuthValidator` | enum (static) | Pure validation | Core/Common — trivially testable |
| `LoginViewModel` / `SignUpViewModel` | `@Observable` classes | Screen state + intents | Feature/Auth |
| `RootViewModel` | `@Observable` class | Restore + observe session → route | App |
| `StubAuthRepository` | test double | Deterministic auth outcomes | Tests |

## Folder Structure Changes

```
Domain/Model/          Domain/Repository/      Domain/UseCase/
Data/Mapper/           Data/Repository/
Core/Networking/       Core/Networking/DTO/    Core/Networking/Resources/
ConnectHubTests/       ConnectHubTests/Support/
```

The project also gained a `ConnectHubTests` unit-test target and a shared `ConnectHub` scheme (so `xcodebuild test` and CI can run the suite).

## Interview Notes

- **Why repositories behind protocols?** They invert the dependency: use cases depend on an abstraction, so the real fake service (or a test stub, or a future `URLSession` client) is an implementation detail. It also makes the domain layer pure and testable.
- **Where does validation belong — view model or use case?** Client-side field validation lives in the view model (immediate UX feedback via `AuthValidator`); the "server" (fake service) enforces its own rules (e.g. the blocked email). Both matter.
- **How is the session observed without Combine?** `DefaultSessionRepository` vends an `AsyncStream<Session?>` that emits the current value on subscribe and again on every save/clear. `RootViewModel` consumes it with `for await`, so signing in or out reactively re-routes the app.
- **Why map DTO → domain at all?** It decouples the UI/business rules from the wire format. If the JSON shape changes, only the mapper changes. Optionals and `URL` parsing are handled once, at the boundary.
- **How do you keep async view-model tests deterministic?** Inject a stub repository with a fixed outcome, `await` the intent method, then assert on the resulting state — no real delay, no shared state (each test uses an isolated `UserDefaults` suite).

## Learning Checklist

- ✅ Define service protocols and a fake backed by bundled JSON
- ✅ Separate DTO / domain models with mappers
- ✅ Implement repositories behind domain protocols
- ✅ Write single-purpose use cases (`callAsFunction`)
- ✅ Build `@Observable` view models with loading/validation/error state
- ✅ Persist a session and observe it via `AsyncStream`
- ✅ Wire dependency injection through a composition root
- ✅ Set up a hosted Swift Testing target with protocol fakes
- ✅ Write parameterized tests and async view-model tests
- □ SwiftData offline cache (Phase 3)
- □ Actor-backed concurrency (Phase 6)

## Future Improvements

- Store the token in the Keychain instead of `UserDefaults` (the `SessionStore` seam already isolates this).
- Add "forgot password" and form-level focus management / return-key navigation.
- Surface a transient success toast on sign-up.
- Extract `AuthValidator` rules into reusable, composable validators as more forms appear.
