# Learning Notes

Every iOS / Swift concept ConnectHub demonstrates, with where to find it in the code. Read this alongside the per-phase summaries for the "why".

---

## SwiftUI

- **Declarative views & composition** — small, reusable `CH*` components (`Core/DesignSystem`), previews on every component.
- **State & data flow** — `@State`, `@Binding`, `@Bindable`, `@Environment`. Views are stateless; state lives in `@Observable` view models.
- **Navigation** — `NavigationStack` with typed paths (`[MainRoute]`), a single `navigationDestination(for:)` table, `TabView` with per-tab stacks, sheets, and toolbars.
- **Lists & scrolling** — `List` with `.listStyle(.plain)`, `.refreshable` pull-to-refresh, `.swipeActions` (conditional), `ScrollViewReader` auto-scroll, `.searchable` + `ContentUnavailableView.search`.
- **Presentation** — `.sheet`, `.confirmationDialog`, `.safeAreaInset` docked input bars.
- **Images & media** — `AsyncImage` with loading/failure phases.
- **Theming** — semantic + adaptive colors, `.preferredColorScheme` driven by settings, Dynamic Type via system text styles, light/dark support.
- **Animation** — `withAnimation`, `.contentTransition(.numericText())`, a hand-rolled `TypingIndicator`.

## Observation & state management

- **`@Observable` (Observation framework)** — all stores and view models; fine-grained, property-level invalidation across object boundaries.
- **Unidirectional flow** — read-only state out, intents in as methods.
- **Explicit state enums** — `FeedState`, `CommentsViewModel.State`, `RootViewModel.Phase`, etc. model loading/empty/loaded/error.

## Swift 6 concurrency

- **Swift 6 language mode**, strict concurrency, `MainActor`-by-default isolation, `Sendable` value types.
- **`async/await`** for one-shot work (login, refresh, load).
- **`actor`** — `MessageStore` serializes concurrent chat writes; proven with a 200-append `TaskGroup` test.
- **`AsyncStream`** — the observation primitive throughout (session, feed, comments, bookmarks, conversations, messages, typing). `AsyncStream.makeStream()` + continuations, `onTermination` cleanup, `for await` consumption.
- **Structured concurrency** — `Task`, child tasks (optimistic send → background reply), `withTaskGroup`, task cancellation via `.task`.
- **`@MainActor` / `nonisolated`** — UI on the main actor; `nonisolated` where a helper must cross the boundary (e.g. the adaptive `Color(light:dark:)`).

## Combine

- **Debounce** — the one place Combine shines: `PassthroughSubject` → `.debounce(for:scheduler:)` → `.removeDuplicates()` → `.sink`, bridged into an `@Observable` search view model with `@ObservationIgnored` plumbing.

## SwiftData

- **`@Model`** — `PostEntity`, `CommentEntity`; `@Attribute(.unique)`.
- **`ModelContainer` / `ModelContext`** — schema in `PersistenceController`, injected via `.modelContainer`; container held strongly by repositories.
- **Querying** — `FetchDescriptor`, `#Predicate`, `SortDescriptor`, `fetchLimit`, bulk `delete(model:)`.
- **Offline-first** — cache as source of truth, upsert preserving local state, in-memory containers for tests.

## Architecture

- **Layered, dependency-inverted design** — App / Feature / Domain / Data / Core / DI.
- **Protocol-based dependency injection** — a single `AppEnvironment` composition root; no singletons.
- **Repository pattern** — protocols in domain, implementations in data; one store can serve multiple protocol "views".
- **Use cases** — single-purpose intents via `callAsFunction`.
- **DTO / `@Model` / domain / UI-model separation** with mappers.

## Persistence & preferences

- **`UserDefaults` behind stores** — never read from views; session, settings, recent searches, `Codable` profile.
- **`Codable`** — DTO decoding from bundled JSON with `.iso8601` dates; persisting the profile.

## Networking (faked)

- **Protocol services + fakes** — bundled JSON, `Task.sleep` latency, error toggle, replaceable by a real client.

## Testing

- **Swift Testing** — `@Test`, `#expect`, `#require`, parameterized `@Test(arguments:)`, `#expect(throws:)`, `@Suite(.serialized)`, `@MainActor` suites.
- **Protocol fakes**, in-memory `ModelContainer`, isolated `UserDefaults` suites, `TaskGroup` concurrency tests.

## Foundation & tooling

- **`RelativeDateTimeFormatter`**, `Duration`, `URL`, `UUID`, `Bundle` resource loading.
- **Conventional Commits**, an open-source repo layout, and a GitHub Actions iOS CI workflow.

---

For concept-by-phase introductions, see [`PHASE_1_SUMMARY.md`](PHASE_1_SUMMARY.md) → [`PHASE_6_SUMMARY.md`](PHASE_6_SUMMARY.md).
