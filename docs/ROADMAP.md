# Roadmap

ConnectHub was built in seven documented phases. All are complete; what follows the checklist is the forward-looking backlog.

---

## Completed

- [x] **Phase 1 — Foundation:** design system, DI, type-safe navigation, app shell.
- [x] **Phase 2 — Fake Auth + Session:** login/sign-up, persisted session.
- [x] **Phase 3 — Feed + Offline Cache:** SwiftData offline-first feed, like/bookmark, pagination.
- [x] **Phase 4 — Post Detail + Comments + Create Post.**
- [x] **Phase 5 — Search + Bookmarks + Profile + Edit Profile.**
- [x] **Phase 6 — Chat + Notifications + Settings:** actor-backed messaging.
- [x] **Phase 7 — Open-Source Polish:** docs, community files, CI.

## Backlog / future improvements

Grouped by area; each item is small and self-contained.

### Persistence & data

- Persist chat messages durably via a SwiftData `@ModelActor` so conversations survive relaunch.
- Reconcile server `likeCount`/`commentCount` with local adjustments (base + local delta).
- Normalize authors into their own `@Model` with a relationship instead of denormalizing onto posts.
- Image caching so `AsyncImage` doesn't re-fetch.

### Features

- Comment editing and reply threads.
- Real follower/following graph instead of seeded counts; open other users' profiles from more entry points.
- Search that also queries a service and merges remote + cached results, with match highlighting.
- Optimistic UI for add/delete comment; a "new posts" indicator on the feed.
- Read receipts / delivery states and richer replies in chat.

### Platform & polish

- Real localization behind the language picker.
- `UserNotifications` + `BGTaskScheduler` for actual local notifications and background refresh.
- Snapshot / UI tests for the design-system components.
- Extract the design system and each feature into local SPM packages as the surface grows.
- Accessibility audit (VoiceOver labels, Dynamic Type at extreme sizes).

### Infrastructure

- Wire a real backend behind the existing `…Service` protocols (callers unchanged).
- Add SwiftLint to the required CI gate once a house style is locked in.
- Release automation (Fastlane) and TestFlight distribution.

Have an idea? Open a [feature request](../.github/ISSUE_TEMPLATE/feature_request.md).
