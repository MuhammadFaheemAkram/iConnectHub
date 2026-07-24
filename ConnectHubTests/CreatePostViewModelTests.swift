//
//  CreatePostViewModelTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
@testable import ConnectHub

@MainActor
struct CreatePostViewModelTests {

    private func makeViewModel(_ postRepo: StubPostRepository) -> CreatePostViewModel {
        let session = makeEphemeralSessionRepository()
        session.save(.sample())
        return CreatePostViewModel(
            createPost: CreatePostUseCase(postRepository: postRepo, sessionRepository: session)
        )
    }

    @Test func blankContentBlocksSubmit() async {
        let repo = StubPostRepository()
        let model = makeViewModel(repo)
        model.content = "   "

        let ok = await model.submit()

        #expect(ok == false)
        #expect(model.contentError != nil)
        #expect(repo.createdContents.isEmpty)
    }

    @Test func overLimitBlocksSubmit() async {
        let repo = StubPostRepository()
        let model = makeViewModel(repo)
        model.content = String(repeating: "a", count: PostValidator.maxLength + 1)

        let ok = await model.submit()

        #expect(ok == false)
        #expect(model.isOverLimit)
        #expect(repo.createdContents.isEmpty)
    }

    @Test func invalidImageURLBlocksSubmit() async {
        let repo = StubPostRepository()
        let model = makeViewModel(repo)
        model.content = "Nice photo"
        model.imageURL = "notaurl"

        let ok = await model.submit()

        #expect(ok == false)
        #expect(model.imageURLError != nil)
        #expect(repo.createdContents.isEmpty)
    }

    @Test func validSubmitCreatesTrimmedPost() async {
        let repo = StubPostRepository()
        let model = makeViewModel(repo)
        model.content = "  Hello ConnectHub  "

        let ok = await model.submit()

        #expect(ok == true)
        #expect(repo.createdContents == ["Hello ConnectHub"])
    }
}
