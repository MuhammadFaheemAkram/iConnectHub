//
//  PostValidator.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Pure validation for creating a post. Kept separate from the view model so
/// the rules are unit-testable.
enum PostValidator {
    static let maxLength = 280

    /// Returns an error message when the content is invalid, else `nil`.
    static func validateContent(_ text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "Write something to share." }
        if text.count > maxLength { return "Posts are limited to \(maxLength) characters." }
        return nil
    }

    /// Optional image URL: empty is fine; otherwise it must be a valid http(s) URL.
    static func validateImageURL(_ text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return nil }
        guard let url = URL(string: trimmed),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              url.host != nil else {
            return "Enter a valid image URL, or leave it empty."
        }
        return nil
    }
}
