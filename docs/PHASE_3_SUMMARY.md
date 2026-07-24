# Phase 3 — Feed + Fake Network + Offline Cache

> The first data-heavy feature. ConnectHub gains a social feed that loads from a fake API, caches to SwiftData, and stays offline-first — plus like, bookmark, pull-to-refresh, and paginated "load more".

---

## Phase Goal

Prove the offline-first data pattern the rest of the app reuses: **the UI observes a local SwiftData cache; the network only ever writes into that cache.** This decouples rendering from the network — the feed shows instantly from cache on launch, refreshes in the background, and survives being offline. It also introduces SwiftData, `@Model` mapping, and paginated loading.

## What Was Implemented

- **Post model layer** — domain `Post`, wire `PostDTO` (ISO-8601 dates), SwiftData `PostEntity` (denormalized author), and `PostMapper` between all three.
- **`FakeFeedService`** — serves a bundled `feed_posts.json` (15 posts), sorted newest-first, in pages of `FeedPaging.pageSize`, with simulated latency and an error toggle.
- **`DefaultFeedRepository`** (SwiftData) — offline-first: exposes `postsStream()` (`AsyncStream`), `refresh(page:)` (upserts a page, preserving local like/bookmark state), and `setLiked`/`setBookmarked`. Every mutation re-queries and emits.
- **Use cases** — `ObserveFeedUseCase`, `RefreshFeedUseCase`, `LikePostUseCase`, `BookmarkPostUseCase`.
- **`FeedViewModel` + `FeedState`** — explicit `loading / empty / loaded / error`, plus paging flags; observes the cache stream and refreshes deterministically.
- **Feed screen** — `PostCard` (avatar, relative time, content, optional image, like/comment/bookmark), pull-to-refresh, load-more on scroll, and all four states.
- **Persistence wiring** — `PersistenceController` (schema + container factory), container injected via `AppEnvironment` and `.modelContainer`.
- **Tests** — feed view-model state transitions, the SwiftData repository (insert, like/bookmark toggles, refresh-preserves-local-state, stream emissions), and the fake service (paging, sorting, details). 34 tests total across the app now pass.

## iOS / Swift Concepts Demonstrated

- **SwiftData** — `@Model`, `ModelContainer`/`ModelContext`, `FetchDescriptor`, `#Predicate`, `@Attribute(.unique)`, in-memory containers for tests.
- **Offline-first architecture** — cache is the source of truth; network writes into it; UI observes it via `AsyncStream`.
- **DTO / `@Model` / domain separation** with a three-way mapper.
- **Pagination** — page fetches, a shared page-size constant, and "load more" on last-cell appearance.
- **`AsyncImage`** with loading/failure phases; **`RelativeDateTimeFormatter`** for timestamps.
- **List UX** — `.refreshable`, `.listRowInsets`, numeric `contentTransition`.
- **Object lifetime under value semantics** — a `ModelContext` is only valid while its `ModelContainer` lives, so the repository must retain the container (see Interview Notes).

## Data Flow

```
FeedView
  ├─ .task → FeedViewModel.observe() ── observes ──▶ ObserveFeedUseCase
  │                                                    → FeedRepository.postsStream()
  │                                                    → SwiftData cache  (offline-first)
  └─ .task → FeedViewModel.refreshIfNeeded()
                → RefreshFeedUseCase → FeedRepository.refresh(page:)
                    → FakeFeedService.feed(page:) (bundled JSON + delay)
                    → PostMapper: PostDTO → PostEntity (upsert into SwiftData)
                    → emit updated posts ──▶ stream ──▶ FeedViewModel → FeedState.loaded

Like / Bookmark: PostCard → FeedViewModel → Like/BookmarkPostUseCase
                  → FeedRepository.setLiked/Bookmarked → SwiftData save → emit → UI
```

## Important Files Added

| File | Purpose |
|------|---------|
| `Domain/Model/Post.swift` | Domain post value type. |
| `Core/Networking/DTO/PostDTO.swift` | Wire model (ISO-8601 date). |
| `Core/Networking/FeedService.swift` | Service protocol + `FeedPaging.pageSize`. |
| `Core/Networking/FakeFeedService.swift` | Bundled-JSON, paged fake. |
| `Core/Networking/Resources/feed_posts.json` | 15 seed posts. |
| `Core/Persistence/PostEntity.swift` | SwiftData `@Model`. |
| `Core/Persistence/PersistenceController.swift` | Schema + `ModelContainer` factory. |
| `Data/Mapper/PostMapper.swift` | DTO ↔ entity ↔ domain. |
| `Data/Repository/DefaultFeedRepository.swift` | Offline-first SwiftData repository. |
| `Domain/Repository/FeedRepository.swift` | Feed boundary + `FeedRefreshResult`. |
| `Domain/UseCase/{ObserveFeed,RefreshFeed,LikePost,BookmarkPost}UseCase.swift` | Feed intents. |
| `Feature/Feed/FeedState.swift`, `FeedViewModel.swift`, `FeedView.swift` | Feed UI + logic. |
| `Core/DesignSystem/PostCard.swift` | Reusable post card. |
| `Core/Common/RelativeTime.swift` | Relative timestamp formatter. |
| `ConnectHubTests/Feed*` | Feed + repository + service tests. |

## Important Types Added

| Type | Kind | Responsibility | Layer |
|------|------|----------------|-------|
| `Post` | domain struct | Feed post value | Domain/Model |
| `PostDTO` | `Codable` struct | Wire model | Core/Networking |
| `PostEntity` | `@Model` class | Cached post | Core/Persistence |
| `FakeFeedService` | struct | Paged fake feed | Core/Networking |
| `DefaultFeedRepository` | `@MainActor` class | Offline-first cache + sync | Data/Repository |
| `FeedRefreshResult` | struct | Posts + fetched-page size | Domain/Repository |
| `FeedViewModel` / `FeedState` | `@Observable` / enum | Feed screen state | Feature/Feed |
| `PostCard` | `View` | Post presentation | Core/DesignSystem |
| `PersistenceController` | enum | Schema + containers | Core/Persistence |

## Folder Structure Changes

```
Core/Persistence/     # PostEntity, PersistenceController (new)
```

Everything else slotted into existing folders (`Domain/Model`, `Domain/Repository`, `Domain/UseCase`, `Data/Mapper`, `Data/Repository`, `Core/Networking`, `Feature/Feed`).

## Interview Notes

- **What makes the feed "offline-first"?** The view model observes SwiftData, never the network. `refresh` fetches a page and upserts it into the cache; the cache emits and the UI updates. On relaunch the cached feed (including your likes/bookmarks) renders immediately, before any network call.
- **How is local state preserved across refreshes?** `upsert` only overwrites server-owned fields (content, author, comment count). `isLiked`/`isBookmarked` and the locally adjusted `likeCount` are left untouched, so a background refresh never clobbers a like.
- **Why does the repository hold the `ModelContainer`, not just the `ModelContext`?** A `ModelContext` is only valid while its container is alive. Holding just `container.mainContext` while the container is a short-lived local caused SwiftData to trap on the next fetch. Retaining the container fixes the lifetime. (This surfaced first in tests, where the helper's container went out of scope.)
- **Why are the SwiftData tests `.serialized`?** Swift Testing runs in parallel by default; each test builds its own store, and standing up multiple containers concurrently is fragile. Serializing that suite keeps it deterministic.
- **DTO vs `@Model` vs domain — why three?** The DTO matches the wire format, the `@Model` matches persistence, and the domain `Post` is what the UI and business logic use. Mappers isolate change: a JSON shape change touches only the DTO + mapper.

## Learning Checklist

- ✅ Model data with SwiftData `@Model` and a `ModelContainer`
- ✅ Query with `FetchDescriptor` / `#Predicate`, sort, and upsert
- ✅ Build an offline-first repository that observes the cache via `AsyncStream`
- ✅ Map DTO ↔ entity ↔ domain with dedicated mappers
- ✅ Model explicit list states (loading/empty/loaded/error)
- ✅ Implement pull-to-refresh and paginated load-more
- ✅ Use `AsyncImage` and relative time formatting
- ✅ Test SwiftData with in-memory containers and serialized suites
- □ Post detail, comments, create post (Phase 4)
- □ Bookmarks screen reusing this cache (Phase 5)

## Future Improvements

- Normalize authors into their own `@Model` with a relationship instead of denormalizing.
- Reconcile server `likeCount` with local likes (e.g. store a base count + local delta).
- Cache images (currently `AsyncImage` re-fetches).
- Add a background refresh / "new posts" indicator; paginate deletions so a hard refresh can prune.
