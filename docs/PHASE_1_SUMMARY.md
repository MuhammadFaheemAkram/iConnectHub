# Phase 1 — Foundation

> Beginner-to-intermediate friendly walkthrough of the ConnectHub foundation. This is the scaffolding every later phase builds on: a design system, a dependency-injection root, type-safe navigation, and a runnable app shell.

---

## Phase Goal

Before writing any real feature, a portfolio-quality app needs a spine: consistent styling, one place to assemble dependencies, a navigation system that scales, and a root that cleanly separates the signed-out and signed-in worlds. Phase 1 delivers exactly that and nothing more — no networking, no database yet — so later phases plug into a stable structure instead of reshaping it.

Where it fits in iOS architecture: this phase establishes the **outer rings** (Core: design system, storage, navigation; DI: composition root; App: entry + flows) and stubs the **Feature** ring with placeholder screens. The Domain and Data layers arrive when the first real feature (auth) needs them in Phase 2.

## What Was Implemented

- **Project configuration** aligned to the conventions: iOS 17.0 deployment target, **Swift 6 language mode** with strict concurrency, `MainActor`-by-default actor isolation, bundle id `BitFuse.ConnectHub`.
- **Design system base** (`Core/DesignSystem`): a `Theme` of color/spacing/radius/typography tokens plus reusable components — `CHButton`, `CHTextField`, `CHAvatar`, `CHLoadingState`, `CHEmptyState`, `CHErrorState`, and a `PlaceholderScreen` scaffold. Light/dark and Dynamic Type supported.
- **Storage** (`Core/Storage`): `SessionStore` (persisted session, source of truth for auth state) and `SettingsStore` (appearance preference driving the app color scheme).
- **Navigation** (`Core/Navigation`): `AuthRoute`, `MainRoute`, `MainTab` enums and a `Router` that owns per-tab typed navigation paths and modal state.
- **Composition root** (`DI/AppEnvironment`): assembles and injects the shared stores.
- **App shell** (`App/`): `ConnectHubApp` entry, `RootView` (session check → route), `SplashView`, `AuthFlowView`, `MainFlowView`.
- **Placeholder feature screens** for all 15 planned screens, wired into real navigation. Auth screens perform a **fake sign-in** so the whole app is navigable today; Profile has a working **Log Out**; Settings already drives the live **appearance** picker.
- **Docs:** this summary and a comprehensive `README.md`.

Config changes: `IPHONEOS_DEPLOYMENT_TARGET 26.5 → 17.0`, `SWIFT_VERSION 5.0 → 6.0`; removed the template `ContentView.swift`; relocated `ConnectHubApp.swift` into `App/`.

## iOS / Swift Concepts Demonstrated

Only concepts actually introduced this phase:

- **`@Observable` (Observation framework)** — `SessionStore`, `SettingsStore`, `AppEnvironment`, and `Router` are observable classes; views re-render when the specific properties they read change, across object boundaries.
- **`@Environment` dependency injection** — `AppEnvironment` and `Router` are injected and resolved without singletons.
- **`@MainActor` default isolation** — with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, UI types are main-actor by default; value types are made `Sendable` and select helpers `nonisolated` where they cross that boundary.
- **`NavigationStack` with typed paths** — each tab binds to a `[MainRoute]` array; `navigationDestination(for:)` maps routes to screens.
- **Type-safe routing** — `AuthRoute` / `MainRoute` / `MainTab` enums instead of stringly-typed navigation.
- **`async/await` + `Task.sleep`** — `SessionStore.restore()` simulates an async session check behind the splash.
- **`@AppStorage`/`UserDefaults` behind stores** — preferences are never read from views directly.
- **SwiftUI composition** — `@ViewBuilder`, `safeAreaInset`, `toolbar`, `sheet`, `@Bindable`, `#Preview`.

## Data Flow

Phase 1 has no network or database yet, so the flow is the session/appearance loop that gates the app:

```
App launch
  → ConnectHubApp creates AppEnvironment (SessionStore, SettingsStore)
  → RootView.task: await SessionStore.restore()   (async session check)
      ├─ no session  → AuthFlowView  → LoginView/SignUpView
      │                      └─ fake sign-in → SessionStore.signIn(_:)
      └─ has session → MainFlowView (TabView + Router)
                             └─ Profile → SessionStore.signOut() → back to AuthFlow
SettingsStore.appearance → RootView.preferredColorScheme (light/dark/system)
```

The target feature data-flow (`View → ViewModel → UseCase → Repository → SwiftData / Fake API → View`) is established as a shape here and realized from Phase 3.

## Important Files Added

| File | Purpose |
|------|---------|
| `App/ConnectHubApp.swift` | App entry; creates and injects `AppEnvironment`. |
| `App/RootView.swift` | Session check, then routes to Auth or Main; applies color scheme. |
| `App/SplashView.swift` | Branded launch screen shown during the session check. |
| `App/AuthFlowView.swift` | `NavigationStack` hosting Login → Sign Up. |
| `App/MainFlowView.swift` | Five-tab `TabView`; central `MainRoute` destination table; Create Post sheet. |
| `DI/AppEnvironment.swift` | Composition root assembling shared dependencies. |
| `Core/DesignSystem/Theme.swift` | Color/spacing/radius/typography tokens; adaptive `Color(light:dark:)`. |
| `Core/DesignSystem/CHButton.swift` · `CHTextField.swift` · `CHAvatar.swift` | Reusable primitives. |
| `Core/DesignSystem/CHStateViews.swift` | Loading / empty / error states. |
| `Core/DesignSystem/PlaceholderScreen.swift` | Scaffold for not-yet-built screens. |
| `Core/Navigation/AuthRoute.swift` · `MainRoute.swift` · `Router.swift` | Type-safe routes, tabs, and the router. |
| `Core/Storage/SessionStore.swift` · `SettingsStore.swift` | Session and preference stores. |
| `Core/Common/AppError.swift` | Single user-presentable error type. |
| `Feature/**/*View.swift` | Placeholder screens for all 15 planned features. |

## Important Types Added

| Type | Kind | Responsibility | Why it lives here |
|------|------|----------------|-------------------|
| `AppEnvironment` | `@Observable` class | Assemble/inject the object graph | `DI/` — the one composition root |
| `SessionStore` | `@Observable` class | Persist session; expose `isAuthenticated` | `Core/Storage` — single source of truth for auth |
| `SettingsStore` | `@Observable` class | Appearance preference → `ColorScheme` | `Core/Storage` — preferences behind a facade |
| `Session` | `Codable`/`Sendable` struct | Immutable session value | `Core/Storage` — value type crossing actors |
| `Router` | `@MainActor @Observable` class | Per-tab paths + modal state | `Core/Navigation` — centralized nav state |
| `AuthRoute` / `MainRoute` / `MainTab` | `Hashable` enums | Type-safe destinations & tabs | `Core/Navigation` — routing vocabulary |
| `AppError` | `Equatable`/`Sendable` enum | Normalize errors for the UI | `Core/Common` — shared by every layer |
| `CHButton`/`CHTextField`/`CHAvatar`/`CH*State` | `View` structs | Reusable UI primitives | `Core/DesignSystem` — consistent styling |

## Folder Structure Changes

New folders introduced this phase:

```
App/
Core/Common/
Core/DesignSystem/
Core/Navigation/
Core/Storage/
DI/
Feature/{Auth, Feed, PostDetail, CreatePost, Comments, Search, Bookmarks,
         Notifications, ChatList, ChatDetail, Profile, EditProfile, Settings}/
docs/
```

`Core/Networking`, `Core/Persistence`, `Domain`, and `Data` are intentionally deferred to the phases that first populate them.

## Interview Notes

- **Why `@Observable` over `ObservableObject`/`@Published`?** Observation tracks reads at the property level, so a view only re-renders for the exact properties it accesses — less over-invalidation, less boilerplate, and it works across nested objects.
- **How does dependency injection work without a framework?** A single composition root (`AppEnvironment`) constructs dependencies and hands them down via `@Environment`. Constructor injection + protocols (from Phase 2) keep types testable with fakes.
- **How is navigation kept type-safe?** Destinations are enums (`MainRoute`), and `navigationDestination(for:)` maps each case to a view. No stringly-typed identifiers, and paths are plain `[MainRoute]` arrays that are trivial to push/pop/reset.
- **Why separate Auth and Main flows at the root?** They have different lifecycles and navigation. Switching on `isAuthenticated` in `RootView` guarantees no signed-out screen leaks into the signed-in world (and vice versa) and lets each flow own its stack.
- **What does `MainActor`-by-default isolation buy you?** Most app code touches UI, so defaulting to the main actor removes ceremony while the compiler still enforces `Sendable` across the boundaries that actually cross threads.

## Learning Checklist

- ✅ Configure a Swift 6 / strict-concurrency project (iOS 17+)
- ✅ Build a token-based design system (color, spacing, type) with light/dark support
- ✅ Create reusable SwiftUI components with previews
- ✅ Model app state with `@Observable` stores
- ✅ Assemble a composition root and inject via `@Environment`
- ✅ Implement type-safe navigation with `NavigationStack` + route enums
- ✅ Separate auth and main flows behind a session check
- ✅ Persist simple state in `UserDefaults` behind a store
- □ Protocol-based repositories + use cases (Phase 2)
- □ SwiftData persistence & offline-first observation (Phase 3)
- □ Actor-backed concurrency for chat (Phase 6)
- □ Swift Testing with fakes (Phase 2+)

## Future Improvements

- Replace the placeholder fake sign-in with real validation, loading/error states, and a `LoginUseCase` (Phase 2).
- Introduce the Domain and Data layers, fake services, and SwiftData (Phases 2–3).
- Consider extracting the design system and each feature into local SPM packages once the surface grows.
- Add snapshot/UI tests for the design-system components.
- Wire `EditProfile` and the remaining `MainRoute` destinations as their features land.
