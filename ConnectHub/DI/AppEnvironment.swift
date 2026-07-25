//
//  AppEnvironment.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI
import SwiftData

/// Composition root for the app.
///
/// A single object assembles the shared stores, fake services, repositories,
/// and use cases, and is injected into SwiftUI via `@Environment`. Views resolve
/// exactly the dependencies they need instead of reaching for singletons, which
/// keeps the graph explicit and testable.
///
/// Each phase extends this root with the collaborators it introduces:
/// Phase 2 added authentication; Phase 3 adds the SwiftData container and feed.
@MainActor
@Observable
final class AppEnvironment {
    // Persistence
    let modelContainer: ModelContainer

    // Stores
    let sessionStore: SessionStore
    let settingsStore: SettingsStore

    // Auth graph
    let authService: AuthService
    let authRepository: AuthRepository
    let sessionRepository: SessionRepository

    // Feed / post graph (one store backs both the feed list and single posts)
    let feedService: FeedService
    let feedRepository: FeedRepository
    let postRepository: PostRepository

    // Comment graph
    let commentService: CommentService
    let commentRepository: CommentRepository

    // Search / bookmarks / profile
    let searchRepository: SearchRepository
    let bookmarkRepository: BookmarkRepository
    let profileRepository: ProfileRepository

    // Chat / notifications
    let chatService: ChatService
    let chatRepository: ChatRepository
    let notificationService: NotificationService
    let notificationRepository: NotificationRepository

    // Auth use cases
    let loginUseCase: LoginUseCase
    let signUpUseCase: SignUpUseCase
    let logoutUseCase: LogoutUseCase
    let observeSessionUseCase: ObserveSessionUseCase

    init(
        modelContainer: ModelContainer,
        sessionStore: SessionStore,
        settingsStore: SettingsStore,
        authService: AuthService,
        authRepository: AuthRepository,
        sessionRepository: SessionRepository,
        feedService: FeedService,
        feedRepository: FeedRepository,
        postRepository: PostRepository,
        commentService: CommentService,
        commentRepository: CommentRepository,
        searchRepository: SearchRepository,
        bookmarkRepository: BookmarkRepository,
        profileRepository: ProfileRepository,
        chatService: ChatService,
        chatRepository: ChatRepository,
        notificationService: NotificationService,
        notificationRepository: NotificationRepository
    ) {
        self.modelContainer = modelContainer
        self.sessionStore = sessionStore
        self.settingsStore = settingsStore
        self.authService = authService
        self.authRepository = authRepository
        self.sessionRepository = sessionRepository
        self.feedService = feedService
        self.feedRepository = feedRepository
        self.postRepository = postRepository
        self.commentService = commentService
        self.commentRepository = commentRepository
        self.searchRepository = searchRepository
        self.bookmarkRepository = bookmarkRepository
        self.profileRepository = profileRepository
        self.chatService = chatService
        self.chatRepository = chatRepository
        self.notificationService = notificationService
        self.notificationRepository = notificationRepository
        self.loginUseCase = LoginUseCase(authRepository: authRepository, sessionRepository: sessionRepository)
        self.signUpUseCase = SignUpUseCase(authRepository: authRepository, sessionRepository: sessionRepository)
        self.logoutUseCase = LogoutUseCase(sessionRepository: sessionRepository)
        self.observeSessionUseCase = ObserveSessionUseCase(sessionRepository: sessionRepository)
    }

    /// The production graph used by the running app.
    static func live() -> AppEnvironment {
        let modelContainer = PersistenceController.makeContainer()
        let sessionStore = SessionStore()
        let authService = FakeAuthService()
        let feedService = FakeFeedService()
        let commentService = FakeCommentService()
        let chatService = FakeChatService()
        let notificationService = FakeNotificationService()
        let sessionRepository = DefaultSessionRepository(store: sessionStore)
        // One repository backs the feed list, single posts, and bookmarks.
        let postsRepository = DefaultFeedRepository(service: feedService, container: modelContainer)
        return AppEnvironment(
            modelContainer: modelContainer,
            sessionStore: sessionStore,
            settingsStore: SettingsStore(),
            authService: authService,
            authRepository: DefaultAuthRepository(service: authService),
            sessionRepository: sessionRepository,
            feedService: feedService,
            feedRepository: postsRepository,
            postRepository: postsRepository,
            commentService: commentService,
            commentRepository: DefaultCommentRepository(service: commentService, container: modelContainer),
            searchRepository: DefaultSearchRepository(container: modelContainer),
            bookmarkRepository: postsRepository,
            profileRepository: DefaultProfileRepository(sessionRepository: sessionRepository),
            chatService: chatService,
            chatRepository: DefaultChatRepository(service: chatService),
            notificationService: notificationService,
            notificationRepository: DefaultNotificationRepository(service: notificationService)
        )
    }

    /// Builds the root view model that drives auth/main routing.
    func makeRootViewModel() -> RootViewModel {
        RootViewModel(sessionRepository: sessionRepository, observeSession: observeSessionUseCase)
    }

    /// Builds a feed view model wired to the shared feed repository.
    func makeFeedViewModel() -> FeedViewModel {
        FeedViewModel(
            observeFeed: ObserveFeedUseCase(repository: feedRepository),
            refreshFeed: RefreshFeedUseCase(repository: feedRepository),
            likePost: LikePostUseCase(repository: feedRepository),
            bookmarkPost: BookmarkPostUseCase(repository: feedRepository)
        )
    }

    func makeCreatePostViewModel() -> CreatePostViewModel {
        CreatePostViewModel(
            createPost: CreatePostUseCase(postRepository: postRepository, sessionRepository: sessionRepository)
        )
    }

    func makePostDetailViewModel(postId: String) -> PostDetailViewModel {
        PostDetailViewModel(
            postId: postId,
            observePost: ObservePostUseCase(repository: postRepository),
            getDetails: GetPostDetailsUseCase(repository: postRepository),
            observeComments: ObserveCommentsUseCase(repository: commentRepository),
            refreshComments: RefreshCommentsUseCase(repository: commentRepository),
            addComment: AddCommentUseCase(commentRepository: commentRepository, postRepository: postRepository, sessionRepository: sessionRepository),
            likePost: LikePostUseCase(repository: feedRepository),
            bookmarkPost: BookmarkPostUseCase(repository: feedRepository)
        )
    }

    func makeCommentsViewModel(postId: String) -> CommentsViewModel {
        CommentsViewModel(
            postId: postId,
            observeComments: ObserveCommentsUseCase(repository: commentRepository),
            refreshComments: RefreshCommentsUseCase(repository: commentRepository),
            addComment: AddCommentUseCase(commentRepository: commentRepository, postRepository: postRepository, sessionRepository: sessionRepository),
            deleteComment: DeleteCommentUseCase(commentRepository: commentRepository, postRepository: postRepository)
        )
    }

    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(
            search: SearchUseCase(repository: searchRepository),
            observeRecent: ObserveRecentSearchesUseCase(repository: searchRepository),
            addRecent: AddRecentSearchUseCase(repository: searchRepository),
            clearRecent: ClearRecentSearchesUseCase(repository: searchRepository)
        )
    }

    func makeBookmarksViewModel() -> BookmarksViewModel {
        BookmarksViewModel(
            observeBookmarks: ObserveBookmarksUseCase(repository: bookmarkRepository),
            bookmarkPost: BookmarkPostUseCase(repository: feedRepository),
            likePost: LikePostUseCase(repository: feedRepository)
        )
    }

    func makeProfileViewModel(userId: String?) -> ProfileViewModel {
        ProfileViewModel(
            userId: userId,
            observeProfile: ObserveProfileUseCase(repository: profileRepository),
            observeFeed: ObserveFeedUseCase(repository: feedRepository),
            logout: logoutUseCase
        )
    }

    func makeEditProfileViewModel() -> EditProfileViewModel {
        EditProfileViewModel(
            profile: profileRepository.currentProfile(),
            updateProfile: UpdateProfileUseCase(repository: profileRepository)
        )
    }

    func makeChatListViewModel() -> ChatListViewModel {
        ChatListViewModel(
            observeConversations: ObserveConversationsUseCase(repository: chatRepository),
            refreshConversations: RefreshConversationsUseCase(repository: chatRepository)
        )
    }

    func makeChatDetailViewModel(conversationId: String) -> ChatDetailViewModel {
        ChatDetailViewModel(
            conversationId: conversationId,
            observeMessages: ObserveMessagesUseCase(repository: chatRepository),
            observeTyping: ObserveTypingUseCase(repository: chatRepository),
            observeConversations: ObserveConversationsUseCase(repository: chatRepository),
            loadMessages: LoadMessagesUseCase(repository: chatRepository),
            sendMessage: SendMessageUseCase(repository: chatRepository),
            markRead: MarkConversationReadUseCase(repository: chatRepository)
        )
    }

    func makeNotificationsViewModel() -> NotificationsViewModel {
        NotificationsViewModel(
            observeNotifications: ObserveNotificationsUseCase(repository: notificationRepository),
            refreshNotifications: RefreshNotificationsUseCase(repository: notificationRepository),
            markRead: MarkNotificationReadUseCase(repository: notificationRepository),
            markAllRead: MarkAllNotificationsReadUseCase(repository: notificationRepository)
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            clearCache: ClearCacheUseCase(feedRepository: feedRepository),
            logout: logoutUseCase
        )
    }
}
