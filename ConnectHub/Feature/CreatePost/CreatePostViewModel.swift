//
//  CreatePostViewModel.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Drives Create Post: content + optional image URL, a character counter, and
/// validated fake submission that inserts into the feed cache.
@MainActor
@Observable
final class CreatePostViewModel {
    var content = ""
    var imageURL = ""

    private(set) var contentError: String?
    private(set) var imageURLError: String?
    private(set) var generalError: String?
    private(set) var isSubmitting = false

    let characterLimit = PostValidator.maxLength
    var characterCount: Int { content.count }
    var isOverLimit: Bool { content.count > characterLimit }

    private let createPost: CreatePostUseCase

    init(createPost: CreatePostUseCase) {
        self.createPost = createPost
    }

    /// Returns `true` when the post was created, so the view can dismiss.
    func submit() async -> Bool {
        contentError = PostValidator.validateContent(content)
        imageURLError = PostValidator.validateImageURL(imageURL)
        generalError = nil
        guard contentError == nil, imageURLError == nil else { return false }

        isSubmitting = true
        defer { isSubmitting = false }

        let trimmedURL = imageURL.trimmingCharacters(in: .whitespaces)
        let url = trimmedURL.isEmpty ? nil : URL(string: trimmedURL)
        let text = content.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            _ = try await createPost(content: text, imageURL: url)
            return true
        } catch let error as AppError {
            generalError = error.message
            return false
        } catch {
            generalError = AppError.unknown.message
            return false
        }
    }
}
