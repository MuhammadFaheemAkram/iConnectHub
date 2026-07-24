# Phase 5 — Search + Bookmarks + Profile + Edit Profile

> Rounding out the core app. This phase adds debounced search over the local cache (with persisted recent searches), an offline bookmarks screen, and a profile the user can view and edit — all reusing the single SwiftData store and the established repository/use-case pattern.

---

## Phase Goal

Add the three "personal" surfaces of the app while reinforcing two ideas:

1. **The cache is a queryable local database.** Search and bookmarks are just different *views* over the same SwiftData posts store — no new network calls, fully offline.
2. **Combine where it fits.** Search introduces a Combine debounce pipeline (the one place continuous, rate-limited reactive streams beat one-shot `async/await`), as reserved in the stack for search and the chat typing indicator.

Profile adds the app's first user-owned, editable, locally persisted state.

## What Was Implemented

- **Search** — `DefaultSearchRepository` searches cached posts + their authors locally and persists recent searches in `UserDefaults`; `SearchViewModel` debounces the query through **Combine** (`PassthroughSubject.debounce`), and records/clears recent searches. `SearchField` component, People/Posts result sections, recent-searches list, empty/no-results states.
- **Bookmarks** — `BookmarkRepository` (a third protocol on `DefaultFeedRepository`) streams bookmarked posts from the shared store; `BookmarksViewModel` renders them and removes bookmarks; empty state.
- **Profile** — `DefaultProfileRepository` seeds the profile from the session and persists it in `UserDefaults`; `ProfileViewModel` shows avatar, name, bio, follower/following/post counts, and the user's own posts (filtered from the feed cache), plus Edit Profile and Log Out. Works for other users too (derived read-only from the cache) via the `.userProfile` route; `PostCard` now has an `onAuthor` tap.
- **Edit Profile** — `EditProfileViewModel` prefilled from the profile, validates name (reusing `AuthValidator`) and avatar URL (reusing `PostValidator`), enforces a bio limit, and persists via `UpdateProfileUseCase`.
- **Use cases** — `Search`, `ObserveRecentSearches`, `AddRecentSearch`, `ClearRecentSearches`, `ObserveBookmarks`, `ObserveProfile`, `UpdateProfile`.
- **Tests** — 20 new tests (79 total across 19 suites): local search + recent-search management, the bookmark stream, profile persistence/seeding, and the search/bookmarks/edit-profile view models.

## iOS / Swift Concepts Demonstrated

- **Combine** — `PassthroughSubject` + `.debounce(for:scheduler:)` + `.removeDuplicates()` + `.sink`, stored in `Set<AnyCancellable>`, bridged into an `@Observable` model (subject fed from a property `didSet`, `@ObservationIgnored` for Combine plumbing).
- **A third protocol on one store** — `DefaultFeedRepository` now serves feed, single-post, *and* bookmark views, emitting to each observer set on every mutation.
- **Local querying** over the SwiftData cache (case-insensitive content/author matching, unique authors).
- **`UserDefaults` persistence** behind repositories for recent searches and the `Codable` profile.
- **Reusing validators across features** (`AuthValidator.validateName`, `PostValidator.validateImageURL`).
- **Deriving one screen's data from another's cache** (a user's posts filtered from the feed).

## Data Flow

```
Search (debounced):
  SearchField → SearchViewModel.query (didSet → PassthroughSubject)
    → Combine .debounce(300ms).removeDuplicates()
    → SearchUseCase → SearchRepository.search  (local SwiftData query)
    → results (People + Posts)
  submit / pick recent → AddRecentSearchUseCase → persisted recents (UserDefaults) → stream

Bookmarks:
  BookmarksView → ObserveBookmarksUseCase → DefaultFeedRepository.bookmarksStream()
    (filtered from the shared cache; emits on any bookmark change)
  remove → BookmarkPostUseCase(isBookmarked: false) → cache → stream → row disappears

Profile / Edit:
  ProfileView → ObserveProfileUseCase (UserDefaults, seeded from session)
              + ObserveFeedUseCase (filter posts by author id)
  EditProfile → UpdateProfileUseCase → persist → stream → header updates
```

## Important Files Added

| File | Purpose |
|------|---------|
| `Domain/Model/SearchResults.swift` | Users + posts result value. |
| `Domain/Repository/{Search,Bookmark,Profile}Repository.swift` | New boundaries. |
| `Data/Repository/DefaultSearchRepository.swift` · `DefaultProfileRepository.swift` | Local search + profile persistence. |
| `Domain/UseCase/{Search,ObserveRecentSearches,AddRecentSearch,ClearRecentSearches,ObserveBookmarks,ObserveProfile,UpdateProfile}UseCase.swift` | Phase-5 intents. |
| `Core/DesignSystem/SearchField.swift` | Search bar component. |
| `Feature/Search/*`, `Feature/Bookmarks/*`, `Feature/Profile/*`, `Feature/EditProfile/*` | Screens + view models. |
| `ConnectHubTests/{SearchRepository,SearchViewModel,BookmarksViewModel,Profile,BookmarkStream}Tests.swift` | Tests. |

## Important Types Added

| Type | Kind | Responsibility | Layer |
|------|------|----------------|-------|
| `SearchResults` | struct | Users + posts match | Domain/Model |
| `SearchRepository` / `DefaultSearchRepository` | protocol / class | Local search + recents | Domain / Data |
| `BookmarkRepository` | protocol (on `DefaultFeedRepository`) | Bookmark stream | Domain / Data |
| `ProfileRepository` / `DefaultProfileRepository` | protocol / class | Persisted profile | Domain / Data |
| `SearchViewModel` | `@Observable` (+ Combine) | Debounced search + recents | Feature/Search |
| `BookmarksViewModel` / `ProfileViewModel` / `EditProfileViewModel` | `@Observable` | Screen state | Feature |
| `SearchField` | `View` | Search bar | Core/DesignSystem |

## Folder Structure Changes

No new folders — the `Search`, `Bookmarks`, `Profile`, and `EditProfile` feature folders already existed as Phase 1 placeholders and are now implemented.

## Interview Notes

- **Why Combine for search but `async/await` elsewhere?** Debounce is a *time-based, rate-limiting* operation over a stream of values — exactly what Combine's `.debounce` expresses in one line. One-shot work (login, refresh) is clearer with `async/await`. Using each where it fits is the point.
- **How do bookmarks stay in sync with the feed?** `DefaultFeedRepository` is the single owner of the posts store and conforms to `BookmarkRepository`; on any bookmark change it re-filters and emits to the bookmark observers, so the Bookmarks tab updates even when you bookmark from the feed or detail.
- **Where does the profile come from?** It's seeded from the session the first time it's read (name from the display name), then persisted in `UserDefaults` as a `Codable User`. Edits update it and emit on a stream the profile screen observes.
- **How are a user's own posts shown?** The profile observes the feed cache and filters by `author.id`, so posts you create (authored with your session identity) appear on your profile with no extra storage.
- **Is search online?** No — it queries the local SwiftData cache. That keeps it instant and offline; the trade-off is you can only find what's been cached.

## Learning Checklist

- ✅ Build a Combine debounce pipeline inside an `@Observable` model
- ✅ Query the SwiftData cache locally (search)
- ✅ Persist simple state (`UserDefaults`) behind repositories
- ✅ Serve a third observable view from one store (bookmarks)
- ✅ Seed and persist a `Codable` profile; edit + validate it
- ✅ Reuse validators and derive one screen's data from another's cache
- □ Chat (actor-backed), notifications, settings (Phase 6)

## Future Improvements

- Search could also query a fake service and merge remote + cached results.
- Cap/typeahead recent searches; highlight matched substrings in results.
- A real follower/following graph instead of seeded counts.
- Sync the profile display name back onto the user's existing cached posts.
