# Phase 6 — Chat + Notifications + Settings

> The app comes alive. This phase adds actor-backed chat with a simulated reply and typing indicator, an activity/notifications screen with read state, and a full settings screen — completing the feature set.

---

## Phase Goal

Introduce **concurrency done right**. Chat is where multiple things happen at once — the user sends while a reply is being generated — so the message store is a thread-safe `actor`, and the reply/typing flow is driven by `AsyncStream`s. Alongside it, Notifications and Settings round out the app: notification read-state management and the appearance/preferences the design system was built for since Phase 1.

## What Was Implemented

- **Actor-backed chat** — `MessageStore` (`actor`) serializes concurrent sends and received replies; `DefaultChatRepository` coordinates conversation/message/typing `AsyncStream`s and orchestrates the reply flow. `FakeChatService` serves bundled conversations/messages and a delayed canned `simulatedReply`.
- **Chat list** — searchable conversations with participant, last message, time, and unread badge; opening a chat marks it read and moves senders to the top on new messages.
- **Chat detail** — message bubbles (mine vs theirs), an animated **`TypingIndicator`** shown while the reply is generated, optimistic send, and auto-scroll to the newest message.
- **Notifications** — `DefaultNotificationRepository` (in-memory, seeded from `FakeNotificationService`) with mark-one-read and mark-all-read; `NotificationRow` with kind-colored icons and unread styling.
- **Settings** — appearance (System/Light/Dark, live), a notifications toggle, a language picker, Clear Cache (deletes cached posts + comments), Log Out, and About — preferences bound to `SettingsStore`, actions via `SettingsViewModel`.
- **Use cases** — chat (observe conversations/messages/typing, refresh, load, send, mark read), notifications (observe/refresh/markRead/markAllRead), and `ClearCacheUseCase`.
- **Tests** — 16 new tests (95 total across 23 suites): the actor store (incl. **200 concurrent appends stay consistent**), the chat repository (send → reply, typing toggles), and notification read-state.

## iOS / Swift Concepts Demonstrated

- **`actor`** — a thread-safe message store; the whole point tested by hammering it with 200 concurrent appends inside a `TaskGroup`.
- **`AsyncStream` for events** — separate message and typing streams; the typing indicator is driven by `typingStream` emitting `true` before the reply and `false` after (via `defer`).
- **Structured concurrency in a repository** — `send` returns promptly (optimistic append) and spawns the reply in a child `Task`; `withTaskGroup` in tests.
- **`Sendable` across actors** — `Message`/`Conversation` are value types, so results move safely from the actor to the main-actor UI.
- **`ScrollViewReader`** auto-scroll, `.searchable` + `ContentUnavailableView.search`, `.confirmationDialog`, a `Form`-based settings screen bound to an `@Observable` store.

## Data Flow

```
Send a message:
  ChatDetailView → ChatDetailViewModel.send() → SendMessageUseCase
    → ChatRepository.send:
        MessageStore.append(mine)  → messagesStream emits  → bubble appears (optimistic)
        Task { generateReply:
                 typingStream.emit(true)              → TypingIndicator shows
                 await ChatService.simulatedReply     (delay)
                 MessageStore.append(reply)           → messagesStream emits → reply bubble
                 typingStream.emit(false)             → TypingIndicator hides }

Notifications:
  NotificationsView → observe stream ← DefaultNotificationRepository (seeded from fake)
  markRead / markAllRead → mutate → emit → unread styling updates

Settings:
  SettingsView ⇄ SettingsStore (appearance drives RootView.preferredColorScheme)
  Clear Cache → ClearCacheUseCase → FeedRepository.clearCache() → cache emptied
```

## Important Files Added

| File | Purpose |
|------|---------|
| `Domain/Model/Conversation.swift`, `Message.swift`, `AppNotification.swift` | Chat + notification domain models. |
| `Core/Networking/DTO/ChatDTO.swift`, `NotificationDTO.swift` | Wire models. |
| `Core/Networking/{Chat,Notification}Service.swift` + `Fake…` | Service protocols + fakes. |
| `Core/Networking/Resources/{conversations,messages,notifications}.json` | Seed data. |
| `Data/Repository/MessageStore.swift` | **The actor** message store. |
| `Data/Repository/DefaultChatRepository.swift`, `DefaultNotificationRepository.swift` | Repository impls. |
| `Data/Mapper/ChatMapper.swift`, `NotificationMapper.swift` | DTO→domain. |
| `Domain/Repository/ChatRepository.swift`, `NotificationRepository.swift` | Boundaries. |
| `Domain/UseCase/*` (chat, notifications, clear cache) | Phase-6 intents. |
| `Core/DesignSystem/{MessageBubble,TypingIndicator,ConversationRow,NotificationRow}.swift` | Components. |
| `Feature/{ChatList,ChatDetail,Notifications,Settings}/*ViewModel.swift` + views | Screens. |
| `ConnectHubTests/{MessageStore,ChatRepository,NotificationRepository,NotificationsViewModel}Tests.swift` | Tests. |

## Important Types Added

| Type | Kind | Responsibility | Layer |
|------|------|----------------|-------|
| `MessageStore` | `actor` | Thread-safe message state | Data/Repository |
| `DefaultChatRepository` | `@MainActor` class | Streams + reply orchestration | Data/Repository |
| `Conversation` / `Message` / `AppNotification` | `Sendable` structs | Chat + notification models | Domain/Model |
| `ChatRepository` / `NotificationRepository` | `@MainActor` protocols | Boundaries | Domain/Repository |
| `ChatListViewModel` / `ChatDetailViewModel` / `NotificationsViewModel` / `SettingsViewModel` | `@Observable` | Screen state | Feature |
| `TypingIndicator` / `MessageBubble` / `ConversationRow` / `NotificationRow` | `View` | Components | Core/DesignSystem |

## Folder Structure Changes

No new folders — the `ChatList`, `ChatDetail`, `Notifications`, and `Settings` feature folders existed as Phase 1 placeholders and are now implemented. `MessageStore` (the actor) lives beside the repositories in `Data/Repository`.

## Interview Notes

- **Why an `actor` for messages?** Sends and received replies can race — the reply arrives on a background task while the user may be sending again. An `actor` serializes all mutations without locks, so the message list can't corrupt. The test proves it with 200 concurrent appends.
- **How does the typing indicator work without polling?** The repository owns a `typingStream` (`AsyncStream<Bool>`); it emits `true` before awaiting the simulated reply and `false` after (guaranteed by `defer`). The view model observes it into an `isTyping` flag.
- **Why is the sent message "optimistic"?** `send` appends the user's message and emits immediately, so the bubble shows with zero latency; the reply is generated in a background `Task`. UX shouldn't wait on a round-trip.
- **Why AsyncStream here but Combine for search?** Debounce is a rate-limiting operator Combine expresses in a line; chat events are a plain push stream that `AsyncStream` + `for await` model cleanly. Right tool per job.
- **How does appearance switching work app-wide?** `SettingsStore.appearance` maps to a `ColorScheme?` applied at `RootView` via `.preferredColorScheme`. Because the design system uses semantic + adaptive colors, everything re-themes for free.

## Learning Checklist

- ✅ Build a thread-safe `actor` and test it under concurrency (`TaskGroup`)
- ✅ Drive UI events (typing) with `AsyncStream`
- ✅ Orchestrate optimistic send + background reply with structured concurrency
- ✅ Keep `Sendable` value types flowing from an actor to the main-actor UI
- ✅ Manage notification read-state and mark-all-read
- ✅ Build a `Form` settings screen with live appearance, toggle, picker, and destructive actions
- ✅ `ScrollViewReader` auto-scroll and `.searchable` lists

## Future Improvements

- Persist messages durably (e.g. a SwiftData `@ModelActor`) so chats survive relaunch.
- Send read receipts / delivery states; richer reply generation.
- Real localization behind the language picker.
- Per-conversation typing sourced from a shared presence stream.
