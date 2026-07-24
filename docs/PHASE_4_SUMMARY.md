# Phase 4 — Post Detail + Comments + Create Post

> The feed becomes interactive. This phase adds a post detail screen, a full comments experience (add + delete own), and a create-post composer — all offline-first, all sharing one SwiftData store so the feed, detail, and comment counts stay in sync.

---

## Phase Goal

Turn passive posts into a two-way experience while reinforcing the offline-first architecture. Three ideas drive the phase:

1. **One store, two boundaries.** A single SwiftData-backed repository satisfies both `FeedRepository` (the list) and `PostRepository` (single posts), so a like on the detail screen, a new comment's count bump, or a freshly created post all flow through the same store and emit to every observer.
2. **Comments as their own offline-first slice** — a `CommentRepository` mirroring the feed pattern (observe cache, refresh from API, add/delete locally).
3. **Cross-repository use cases** — `AddCommentUseCase` and `DeleteCommentUseCase` coordinate the comment and post repositories to keep the comment count consistent.

## What Was Implemented

- **Comment layer** — domain `Comment`, wire `CommentDTO`, SwiftData `CommentEntity`, `CommentMapper`, `FakeCommentService` (bundled `comments.json`), and `DefaultCommentRepository`.
- **Single-post operations** — `PostRepository` (observe one post, refresh details, **create post**, adjust comment count), implemented by extending `DefaultFeedRepository` (now conforms to both `FeedRepository` and `PostRepository`) with per-post observers.
- **Use cases** — `ObservePostUseCase`, `GetPostDetailsUseCase`, `CreatePostUseCase`, `ObserveCommentsUseCase`, `RefreshCommentsUseCase`, `AddCommentUseCase`, `DeleteCommentUseCase`.
- **Post Detail** — the post card (synced like/bookmark), a comments preview, and an inline add-comment bar.
- **Comments** — a list with swipe-to-delete restricted to own comments, loading/empty/error states, and an add-comment bar; own comments carry a "You" badge.
- **Create Post** — a text editor with a live character counter (280 max), an optional validated image URL, and a fake submit that inserts into the cache so the post appears at the top of the feed immediately.
- **Validation** — `PostValidator` (content + image URL), unit-tested.
- **Tests** — 25 new tests (59 total across 13 suites): validation, both new view models, the comment repository, and single-post/create/add-comment/delete flows over SwiftData.

## iOS / Swift Concepts Demonstrated

- **One type conforming to multiple protocols** to share state (`DefaultFeedRepository: FeedRepository, PostRepository`).
- **Multiple `AsyncStream` observer sets** on one store (list observers + per-post observers) emitted together on each mutation.
- **Cross-repository orchestration in use cases** (add/delete comment ↔ post comment count).
- **`TextEditor`** with a placeholder overlay and a live character counter; **swipe actions** (`.swipeActions`) gated on a condition.
- **`safeAreaInset(edge: .bottom)`** for a docked input bar; returning a `Bool` from a view-model action to drive sheet dismissal.
- **Deriving a domain value from another** (`Session.asAuthor`) at a layer boundary.

## Data Flow

```
Create Post:
  CreatePostView → CreatePostViewModel.submit()
    → PostValidator (content + image URL)
    → CreatePostUseCase → PostRepository.createPost(author: session.asAuthor)
      → SwiftData insert → emit → feed & post streams → post shows atop the feed

Comment (add):
  Comments/Detail → ViewModel → AddCommentUseCase
    → CommentRepository.add (insert own comment) ─┐
    → PostRepository.adjustCommentCount(+1)       ├─ both emit
      → comment list + post comment-count update ─┘

Post Detail:
  PostDetailView → observes ObservePostUseCase (cached post)
                 + ObserveCommentsUseCase (cached comments)
                 → GetPostDetails / RefreshComments pull from the API into the cache
```

## Important Files Added

| File | Purpose |
|------|---------|
| `Domain/Model/Comment.swift` | Domain comment value. |
| `Core/Networking/DTO/CommentDTO.swift` | Wire model. |
| `Core/Networking/CommentService.swift` · `FakeCommentService.swift` | Comment service + fake. |
| `Core/Networking/Resources/comments.json` | Seed comments. |
| `Core/Persistence/CommentEntity.swift` | SwiftData `@Model`. |
| `Data/Mapper/CommentMapper.swift` · `Data/Repository/DefaultCommentRepository.swift` | Comment mapping + repo. |
| `Domain/Repository/PostRepository.swift` · `CommentRepository.swift` | New boundaries. |
| `Domain/UseCase/{ObservePost,GetPostDetails,CreatePost,ObserveComments,RefreshComments,AddComment,DeleteComment}UseCase.swift` | Detail/comment/create intents. |
| `Core/Common/PostValidator.swift` | Create-post validation. |
| `Core/DesignSystem/CommentRow.swift` | Comment row component. |
| `Feature/PostDetail/*`, `Feature/Comments/*`, `Feature/CreatePost/*` | Screens + view models. |
| `ConnectHubTests/{PostValidator,CreatePostViewModel,CommentsViewModel,CommentRepository,PostInteraction}Tests.swift` | Tests. |

## Important Types Added

| Type | Kind | Responsibility | Layer |
|------|------|----------------|-------|
| `Comment` / `CommentDTO` / `CommentEntity` | struct / struct / `@Model` | Comment across layers | Domain / Networking / Persistence |
| `PostRepository` | `@MainActor` protocol | Single-post ops | Domain/Repository |
| `CommentRepository` | `@MainActor` protocol | Offline-first comments | Domain/Repository |
| `DefaultCommentRepository` | `@MainActor` class | SwiftData comments | Data/Repository |
| `AddCommentUseCase` / `DeleteCommentUseCase` | struct | Comment + count orchestration | Domain/UseCase |
| `CreatePostUseCase` | struct | Author + insert a post | Domain/UseCase |
| `PostValidator` | enum | Create-post rules | Core/Common |
| `PostDetailViewModel` / `CommentsViewModel` / `CreatePostViewModel` | `@Observable` | Screen state | Feature |
| `CommentRow` | `View` | Comment presentation | Core/DesignSystem |

## Folder Structure Changes

No new folders — everything slotted into the existing layered structure. `DefaultFeedRepository` grew a second protocol conformance rather than spawning a separate post store.

## Interview Notes

- **Why does one class conform to both `FeedRepository` and `PostRepository`?** They operate on the same posts. Splitting them into two stores would desync likes/counts; one owner with two protocol "views" keeps a single source of truth while letting each screen depend only on the surface it needs.
- **How does a new comment update the feed's comment count?** `AddCommentUseCase` calls the comment repository (insert) *and* `PostRepository.adjustCommentCount(+1)`. The post mutation emits on the shared post stream, so the feed card and detail header update without a refresh.
- **How are "own" comments handled?** They're created with `isOwnComment = true`, marked with a "You" badge, are the only rows that expose swipe-to-delete, and survive server refreshes (the upsert only touches server comment ids).
- **How is the created post shown instantly?** `createPost` inserts a `PostEntity` dated now and emits; because the feed is newest-first and observes the store, the post appears at the top with no network round-trip.
- **Why return `Bool` from `CreatePostViewModel.submit()`?** The view dismisses the sheet only on success; the view model owns the outcome, the view owns the presentation.

## Learning Checklist

- ✅ Model a second SwiftData entity and add it to the schema
- ✅ Expose one store through multiple repository protocols
- ✅ Emit to several observer sets (list + per-item) from one store
- ✅ Orchestrate multiple repositories inside a use case
- ✅ Build a composer with `TextEditor`, a character counter, and validation
- ✅ Implement conditional swipe-to-delete
- ✅ Keep derived counts consistent across screens via shared streams
- □ Search, bookmarks, profile (Phase 5)

## Future Improvements

- Reconcile the post's server comment count with the number of locally cached comments.
- Add comment editing and reply threads.
- Optimistic UI for add/delete (currently waits on the fake latency).
- Image preview in Create Post before submitting.
