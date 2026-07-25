# Changelog

All notable changes to ConnectHub are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project was
built in seven documented phases (see [`docs/`](docs/)).

## [1.0.0] — 2026-07-25

The complete app: a fully offline social experience backed by fake services.

### Added

- **Phase 1 — Foundation:** design system (`CH*` components, theme), `AppEnvironment`
  composition root, type-safe navigation (`AuthRoute`/`MainRoute`/`Router`), root
  auth/main flow switch, five-tab shell.
- **Phase 2 — Fake Auth + Session:** `FakeAuthService`, auth/session repositories,
  login/sign-up/logout/observe-session use cases, validated Login and Sign Up
  screens, persisted session.
- **Phase 3 — Feed + Offline Cache:** SwiftData-backed offline-first feed
  (`FakeFeedService`, `DefaultFeedRepository`), like/bookmark, pull-to-refresh,
  paginated load-more, post cards.
- **Phase 4 — Post Detail + Comments + Create Post:** post detail, comments
  (add/delete own, SwiftData-backed), create post that inserts into the cache.
- **Phase 5 — Search + Bookmarks + Profile:** Combine-debounced local search with
  persisted recent searches, offline bookmarks, editable profile with local
  persistence.
- **Phase 6 — Chat + Notifications + Settings:** actor-backed message store with a
  simulated reply and typing indicator, activity notifications with read state,
  and full settings (appearance, notifications, language, clear cache, about).
- **Phase 7 — Open-Source Polish:** full documentation set (`ARCHITECTURE`,
  `TESTING`, `LEARNING_NOTES`, `INTERVIEW_NOTES`, `ROADMAP`), community files,
  `.github` templates, and an iOS CI workflow.

### Tests

- 95 tests across 23 Swift Testing suites: validation, view-model state machines,
  SwiftData repositories, the actor message store (concurrent consistency),
  search, bookmarks, profile, and notifications.

[1.0.0]: https://github.com/BitFuse/ConnectHub/releases/tag/v1.0.0
