//
//  PostValidatorTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
@testable import ConnectHub

@MainActor
struct PostValidatorTests {

    @Test func validContentPasses() {
        #expect(PostValidator.validateContent("Just shipped something great!") == nil)
    }

    @Test func blankContentFails() {
        #expect(PostValidator.validateContent("") != nil)
        #expect(PostValidator.validateContent("   \n ") != nil)
    }

    @Test func contentAtLimitPassesButOverLimitFails() {
        let atLimit = String(repeating: "a", count: PostValidator.maxLength)
        let overLimit = String(repeating: "a", count: PostValidator.maxLength + 1)
        #expect(PostValidator.validateContent(atLimit) == nil)
        #expect(PostValidator.validateContent(overLimit) != nil)
    }

    @Test func emptyImageURLIsAllowed() {
        #expect(PostValidator.validateImageURL("") == nil)
        #expect(PostValidator.validateImageURL("   ") == nil)
    }

    @Test func validImageURLPasses() {
        #expect(PostValidator.validateImageURL("https://example.com/photo.jpg") == nil)
        #expect(PostValidator.validateImageURL("http://example.com/a.png") == nil)
    }

    @Test func invalidImageURLFails() {
        #expect(PostValidator.validateImageURL("not a url") != nil)
        #expect(PostValidator.validateImageURL("ftp://example.com/a.jpg") != nil)
        #expect(PostValidator.validateImageURL("example.com") != nil)
    }
}
