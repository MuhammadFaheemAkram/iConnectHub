# Architecture

ConnectHub is a layered, unidirectional SwiftUI app built on Swift 6 with strict concurrency. This document explains how the pieces fit together and why.

---

## Principles

1. **Unidirectional data flow.** State flows down, intents flow up.
   `View → @Observable ViewModel → UseCase → Repository → Service/Store → back up as state.`
2. **Dependencies point inward.** The domain layer knows nothing about SwiftUI, SwiftData, or DTOs. Outer layers depend on inner abstractions (protocols), never the reverse.
3. **Single source of truth.** The UI observes local state (SwiftData cache, stores). The network never drives the UI directly — it writes into the cache, which the UI observes.
4. **Explicit states.** Every async surface models **loading / success / empty / error** (plus stale/offline where relevant).
5. **Everything is testable.** Protocol-based dependency injection means every collaborator can be faked.

## Layers

```
┌────────────────────────────────────────────────────────────────┐
│  App            ConnectHubApp, RootView, Auth/Main flow          │
├────────────────────────────────────────────────────────────────┤
│  Feature        Screens: SwiftUI Views + @Observable ViewModels  │
├────────────────────────────────────────────────────────────────┤
│  Domain         Models (plain structs), Repository protocols,    │
│                 UseCases                                          │
├────────────────────────────────────────────────────────────────┤
│  Data           Repository implementations, Mappers,             │
│                 the actor-backed MessageStore                    │
├────────────────────────────────────────────────────────────────┤
│  Core           DesignSystem, Navigation, Storage, Networking    │
│                 (fake services + DTOs + JSON), Persistence,       │
│                 Common                                            │
├────────────────────────────────────────────────────────────────┤
│  DI             AppEnvironment (composition root)                │
└────────────────────────────────────────────────────────────────┘
```

- **Views** are mostly stateless: they render state and send intents via method calls.
- **ViewModels** are `@Observable`, expose read-only state, and receive intents as methods.
- **UseCases** are small, single-purpose types (`callAsFunction`) that orchestrate repositories.
- **Repositories** hide data sources behind protocols defined in the domain layer.
- **Services** are the fake network boundary (`protocol …Service: Sendable`), backed by bundled JSON with simulated latency.

## The four model kinds

A given concept can exist in up to four shapes, each in its own layer, with mappers between them:

| Kind | Example | Lives in | Purpose |
|------|---------|----------|---------|
| **DTO** (`Codable`) | `PostDTO` | Core/Networking | Wire format decoded from JSON |
| **`@Model`** | `PostEntity` | Core/Persistence | SwiftData persistence |
| **Domain** (plain struct) | `Post` | Domain/Model | What business logic + UI use |
| **UI model** (when useful) | `FeedState` | Feature | Screen-specific state |

Mappers (`PostMapper`, `CommentMapper`, `ChatMapper`, …) translate at the boundaries, so a change to the wire format touches only the DTO + mapper.

## Composition root (dependency injection)

`AppEnvironment` (in `DI/`) is the single place the object graph is assembled. It is created once in `ConnectHubApp` and injected via `.environment(...)`. Views resolve exactly what they need with `@Environment`, and view models are built by `make…ViewModel()` factory methods on the environment — no singletons, no service locators.

```
ConnectHubApp
  └─ AppEnvironment.live()   // builds services → repositories → use cases
       └─ .environment(environment)  → every screen
```

Swapping any collaborator (e.g. a real `URLSession` client for a `FakeService`) is a one-line change in `live()`; tests inject fakes directly.

## Navigation

- **Root:** `RootView` runs a session check (`RootViewModel` observing the session stream) and switches between **AuthFlow** and **MainFlow** — the signed-out and signed-in worlds never overlap.
- **AuthFlow:** a `NavigationStack` with Login as root and Sign Up pushed via `AuthRoute`.
- **MainFlow:** a five-tab `TabView` (Feed, Search, Bookmarks, Activity, Profile), each tab its own `NavigationStack`. A shared `Router` owns per-tab typed paths (`[MainRoute]`) and modal state. Detail screens are pushed via the `MainRoute` enum; Chats and Settings are reached from toolbars (no drawer — iOS-idiomatic). Create Post and Edit Profile are sheets.

Everything is type-safe: destinations are enums resolved by a single `navigationDestination(for:)` table in the App layer, which keeps the Core navigation types free of feature imports.

## Offline-first data flow

The defining pattern (feed, bookmarks, comments):

```
View → ViewModel
   ├─ observes ─▶ Repository.stream()  ──▶ SwiftData cache  (source of truth)
   └─ refresh  ─▶ Repository.refresh() ──▶ FakeService (JSON + delay)
                    → Mapper: DTO → @Model (upsert, preserving local state)
                    → emit ──▶ stream ──▶ ViewModel → .loaded
```

- The cache renders **instantly** on launch (including your likes/bookmarks), before any "network" call.
- Refresh **upserts**: server-owned fields update; local state (`isLiked`, `isBookmarked`, own comments) is preserved.
- **One store, many views:** `DefaultFeedRepository` conforms to `FeedRepository`, `PostRepository`, and `BookmarkRepository`. It owns the single posts store and maintains separate observer sets (list / per-post / bookmarks), emitting to all of them on every mutation — so a like on the detail screen, a new comment's count, or a created post stay in sync everywhere.

## Concurrency model

- The project builds in **Swift 6 language mode** with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`: UI-facing types are main-actor by default; value types are `Sendable`.
- **`async/await`** for one-shot work; `AsyncStream` for observation (session, feed, comments, conversations, messages, typing).
- **Combine** appears in exactly one place — the debounced search query (`PassthroughSubject.debounce`) — the rate-limiting stream operator it's ideal for.
- **`actor MessageStore`** backs chat: it serializes concurrent sends and received replies. The repository drives an optimistic-send → background-reply flow, with the typing indicator emitted on an `AsyncStream<Bool>` (`true` before the simulated reply, `false` after via `defer`). `Message`/`Conversation` are `Sendable`, so results move safely from the actor to the main-actor UI.

## Fake network layer

Each service is a `Sendable` protocol with a `Fake…Service` implementation that:

- decodes **bundled JSON** with `Codable`,
- simulates latency with `Task.sleep`,
- exposes a `shouldThrowError = false` toggle for the error path,
- is structured so a real `URLSession` implementation could replace it with no changes to callers.

## Persistence

- **SwiftData** is the local store for offline-capable data (`PostEntity`, `CommentEntity`), defined by `PersistenceController` and injected via `.modelContainer`. Repositories hold the `ModelContainer` strongly (a `ModelContext` is only valid while its container lives).
- **`UserDefaults`** (behind stores/repositories, never read from views) holds simple preferences: session, appearance/notifications/language settings, recent searches, and the editable profile.

### SwiftData → Core Data mapping

SwiftData is a declarative wrapper over Core Data. `@Model` ↔ `NSManagedObject` entity, `ModelContainer` ↔ `NSPersistentContainer`, `ModelContext` ↔ `NSManagedObjectContext`, `FetchDescriptor`/`#Predicate` ↔ `NSFetchRequest`/`NSPredicate`. Because the mental model matches, the persistence layer could be re-implemented on Core Data without touching the domain or UI.

## Folder structure

```
ConnectHub/
├── App/          ConnectHubApp, RootView, Splash, Auth/Main flows, RootViewModel
├── Core/
│   ├── Common/       AppError, RelativeTime, AuthValidator, PostValidator
│   ├── DesignSystem/ Theme + CH* components (buttons, cards, rows, states, …)
│   ├── Navigation/   AuthRoute, MainRoute, MainTab, Router
│   ├── Storage/      SessionStore, SettingsStore
│   ├── Networking/   Service protocols, Fake impls, DTOs, Resources (JSON)
│   └── Persistence/  PersistenceController, PostEntity, CommentEntity
├── Domain/
│   ├── Model/        User, Post, Comment, Conversation, Message, AppNotification, …
│   ├── Repository/   Repository protocols
│   └── UseCase/      One type per intent
├── Data/
│   ├── Mapper/       DTO ↔ @Model ↔ domain
│   └── Repository/   Implementations + MessageStore (actor)
├── Feature/          One folder per screen (View + ViewModel)
└── DI/               AppEnvironment
```

For deeper, phase-by-phase rationale see the [`PHASE_*_SUMMARY.md`](.) documents.
