# Testing

ConnectHub uses **Swift Testing** (`@Test`, `#expect`, `#require`) with protocol-based fakes. As of the final phase there are **95 tests across 23 suites**, all green.

---

## Running the tests

In Xcode: ⌘U. From the command line:

```bash
xcodebuild test -project ConnectHub.xcodeproj -scheme ConnectHub \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

The shared `ConnectHub` scheme wires the `ConnectHubTests` target into the Test action, so CI runs the same command.

## What's covered

| Area | Suites |
|------|--------|
| Validation | `AuthValidatorTests`, `PostValidatorTests` |
| Auth / session | `LoginViewModelTests`, `SignUpViewModelTests`, `SessionRepositoryTests`, `FakeAuthServiceTests` |
| Feed | `FeedViewModelTests`, `FeedRepositoryTests`, `FakeFeedServiceTests` |
| Posts / comments | `PostInteractionTests`, `CommentRepositoryTests`, `CommentsViewModelTests`, `CreatePostViewModelTests` |
| Search / bookmarks / profile | `SearchRepositoryTests`, `SearchViewModelTests`, `BookmarksViewModelTests`, `BookmarkStreamTests`, `ProfileRepositoryTests`, `EditProfileViewModelTests` |
| Chat / notifications | `MessageStoreTests`, `ChatRepositoryTests`, `NotificationRepositoryTests`, `NotificationsViewModelTests` |

## Strategy

- **View models** are tested by injecting a stub repository/use case with a fixed outcome, invoking the intent method (`await model.signIn()`), and asserting on the resulting state. No real delays, no shared state.
- **Repositories over SwiftData** use an in-memory `ModelContainer` (`PersistenceController.makeContainer(inMemory: true)`), so each test gets an isolated store.
- **Stores over `UserDefaults`** use an isolated suite (`UserDefaults(suiteName: "ConnectHubTests.\(UUID())")`).
- **The actor message store** is hammered with 200 concurrent appends inside a `TaskGroup` to prove serialization keeps it consistent.
- **Streams** are read with a small `firstValue(_:)` helper (the repositories yield the current value on subscribe), or drained by a collector `Task` when asserting a sequence of emissions.

Test doubles and sample factories live in `ConnectHubTests/Support/` (`TestSupport`, `FeedTestSupport`, `CommentTestSupport`, `Phase5TestSupport`, `Phase6TestSupport`).

## Two gotchas worth knowing

1. **`@MainActor` on test suites.** The app builds with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, so app functions/types are main-actor-isolated. Test suites that call them are annotated `@MainActor`. The test target itself keeps the default (nonisolated), which lets `Sendable` stub types (e.g. `StubAuthRepository`) satisfy the nonisolated protocol requirements.
2. **Serialize SwiftData suites.** Swift Testing runs in parallel by default. Suites that stand up their own `ModelContainer` are marked `@Suite(.serialized)` — creating multiple containers concurrently is fragile. Also: a repository must **retain its `ModelContainer`** (holding only `container.mainContext` while the container deallocates makes SwiftData trap on the next fetch — this surfaced first in a test).

## Example

```swift
@MainActor
struct FeedViewModelTests {
    @Test func refreshLoadsPosts() async {
        let repo = StubFeedRepository()
        let posts = [Post.sample(id: "a"), Post.sample(id: "b")]
        repo.refreshResult = FeedRefreshResult(posts: posts, fetchedCount: 2)
        let model = FeedViewModel(/* use cases wrapping repo */)

        await model.refresh()

        #expect(model.state == .loaded(posts))
    }
}
```

## Adding a test

1. Put it beside the existing suites in `ConnectHubTests/`.
2. Reuse or extend a `*TestSupport` file for stubs and sample factories.
3. Mark the suite `@MainActor` if it touches app types; add `@Suite(.serialized)` if it builds a SwiftData container.
4. Prefer asserting on state produced by an intent over asserting on implementation details.
