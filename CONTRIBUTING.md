# Contributing to ConnectHub

Thanks for your interest! ConnectHub is a portfolio-quality reference project, and contributions that keep it clean, consistent, and well-documented are very welcome.

## Ground rules

- Be respectful — see the [Code of Conduct](CODE_OF_CONDUCT.md).
- Keep the architecture intact (see [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)). New features follow the existing **View → `@Observable` ViewModel → UseCase → Repository → Service/Store** flow.
- Every async surface models **loading / success / empty / error** explicitly.
- Match the surrounding style; add brief comments only to explain *why*, not *what*.

## Getting started

**Requirements:** macOS with **Xcode 26** (iOS 17+ SDK).

```bash
git clone <your-fork-url>
cd ConnectHub
open ConnectHub.xcodeproj
```

Build and run with ⌘R on any iOS 17+ simulator.

## Development workflow

1. Create a branch: `git checkout -b feat/short-description`.
2. Make your change, keeping DTO / `@Model` / domain / UI models separated with mappers.
3. Add or update tests (Swift Testing) — see [`docs/TESTING.md`](docs/TESTING.md).
4. Ensure the project builds and all tests pass:
   ```bash
   xcodebuild test -project ConnectHub.xcodeproj -scheme ConnectHub \
     -destination 'platform=iOS Simulator,name=iPhone 17'
   ```
5. If SwiftLint is installed, run `swiftlint` and resolve warnings.
6. Open a pull request using the template.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/): `type(scope): message`.

```
feat(feed): add pull-to-refresh haptics
fix(chat): keep typing indicator on rapid sends
docs(readme): clarify offline behavior
test(search): cover empty-query path
refactor(core): extract relative-time helper
```

## Project conventions

- SwiftUI + Observation (`@Observable`), `async/await`/actors, SwiftData, Swift Testing.
- Protocol-based dependency injection via the single `AppEnvironment` composition root.
- Fake services back everything; there is no real network.

Questions? Open a discussion or issue. Happy building!
