# Interview Notes

Questions this project prepares you to answer, grounded in ConnectHub's code. Use them to rehearse explaining real decisions rather than reciting definitions.

---

## Architecture & design

**Q: Walk me through the app's architecture.**
Layered and unidirectional: `View → @Observable ViewModel → UseCase → Repository → Service/Store`, with dependencies pointing inward. The domain layer (plain models, repository protocols, use cases) knows nothing about SwiftUI, SwiftData, or DTOs. A single `AppEnvironment` composition root wires everything and is injected via `@Environment`.

**Q: Why use cases instead of calling repositories from view models?**
Use cases name the business intent (`LikePostUseCase`, `SendMessageUseCase`) and orchestrate across repositories when needed — e.g. `AddCommentUseCase` adds a comment *and* bumps the post's comment count. They keep view models declarative and give a single, testable place for orchestration.

**Q: How do you keep the UI decoupled from the network?**
The UI observes the local cache (SwiftData) or stores — never the network. Services only ever write into the cache; the cache emits and the UI updates. This makes the app offline-first and means "network down" is just "no refresh".

**Q: One store serves feed, detail, and bookmarks. Why, and how?**
They're all views over the same posts. `DefaultFeedRepository` conforms to `FeedRepository`, `PostRepository`, and `BookmarkRepository`, owns one SwiftData store, and keeps separate observer sets (list / per-post / bookmarks). Every mutation re-queries and emits to all of them, so a like or a new comment stays in sync everywhere — with a single source of truth.

## Concurrency

**Q: Why is the chat message store an `actor`?**
Chat has genuine concurrency — a reply arrives on a background task while the user may be sending again. An `actor` serializes all mutations without manual locks, so the message list can't corrupt. A test appends 200 messages concurrently via `TaskGroup` and asserts the count.

**Q: How does the typing indicator work?**
The chat repository exposes a `typingStream` (`AsyncStream<Bool>`). When sending, it emits `true` before awaiting the delayed simulated reply and `false` afterward (guaranteed by `defer`). The view model observes it into an `isTyping` flag that shows/hides an animated bubble. No polling.

**Q: When do you reach for Combine vs async/await?**
`async/await` for one-shot work (login, refresh). `AsyncStream` for observation. **Combine** for the one thing it's uniquely good at here — debouncing the search query (`PassthroughSubject.debounce`). Right tool per job, not dogma.

**Q: What does Swift 6 strict concurrency change day-to-day?**
Data races become compile errors. With `MainActor`-by-default isolation, UI code is main-actor without ceremony, and the compiler forces value types crossing actor boundaries to be `Sendable`. The chat actor returns `Sendable` `Message` values, so they're safe to hand to the main-actor UI.

## SwiftData & persistence

**Q: DTO vs `@Model` vs domain model — why three?**
Each matches a different concern: the DTO matches the wire format, the `@Model` matches persistence, and the domain struct is what business logic and the UI use. Mappers isolate change — a JSON shape change touches only the DTO and its mapper.

**Q: A subtle SwiftData bug you hit?**
A `ModelContext` is only valid while its `ModelContainer` is alive. Holding only `container.mainContext` while the container was a short-lived local made SwiftData trap (SIGTRAP) on the next fetch. Fix: the repository retains the container. It surfaced first in a test, where the helper's container went out of scope.

**Q: How is offline like/bookmark state preserved across refreshes?**
`upsert` only overwrites server-owned fields (content, counts, author). `isLiked`/`isBookmarked` and locally added comments are left untouched, so a background refresh never clobbers a local action.

**Q: SwiftData or Core Data?**
SwiftData here for its declarative `@Model`/`@Query` ergonomics. It maps cleanly onto Core Data (`ModelContainer`↔`NSPersistentContainer`, `#Predicate`↔`NSPredicate`), so the persistence layer could be swapped without touching the domain or UI.

## State & SwiftUI

**Q: `@Observable` vs `ObservableObject`/`@Published`?**
Observation tracks reads at the property level, so a view re-renders only for the exact properties it accesses — less over-invalidation and less boilerplate — and it works across nested objects.

**Q: How do you model async screen state?**
An explicit enum (`FeedState`: `loading / empty / loaded([Post]) / error(String)`). The view switches over it; there are no ambiguous "is it loading or empty?" booleans.

**Q: How is navigation kept type-safe?**
Destinations are enums (`MainRoute`), resolved by one `navigationDestination(for:)` table. Paths are `[MainRoute]` arrays — trivial to push/pop/reset. No stringly-typed identifiers.

## Testing

**Q: How do you test an `@Observable` view model with async work?**
Inject a stub repository with a fixed outcome, `await` the intent method, and assert on the resulting state. No real delays; each test is isolated (in-memory `ModelContainer` or a unique `UserDefaults` suite).

**Q: How do you test concurrency?**
For the actor store, spawn 200 concurrent appends with `withTaskGroup` and assert the final count — if serialization broke, appends would be lost.

## Product & trade-offs

**Q: What would you change for production?**
Keychain-store the session token (the `SessionStore` seam isolates this), persist chat messages durably (a SwiftData `@ModelActor`), reconcile server vs local counts, real localization behind the language picker, image caching, and a real backend behind the existing service protocols — which callers wouldn't notice.

**Q: What are you most proud of?**
The offline-first single-source-of-truth pattern and the clean concurrency story — one store observed everywhere, an actor for chat, and Swift 6 strict concurrency passing with no data-race escapes.
