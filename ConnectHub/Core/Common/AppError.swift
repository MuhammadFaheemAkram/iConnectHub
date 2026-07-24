//
//  AppError.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// A single, user-presentable error type that every layer maps into.
///
/// Keeping one domain error keeps view models simple: they only ever surface
/// an `AppError`, never a raw `URLError`, decoding error, or SwiftData failure.
enum AppError: Error, Equatable, Sendable {
    case network
    case notFound
    case unauthorized
    case validation(String)
    case decoding
    case unknown

    /// A short, human-readable message safe to show in the UI.
    var message: String {
        switch self {
        case .network:
            return "Something went wrong with your connection. Please try again."
        case .notFound:
            return "We couldn't find what you were looking for."
        case .unauthorized:
            return "Your session has expired. Please sign in again."
        case .validation(let message):
            return message
        case .decoding:
            return "We received an unexpected response. Please try again."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
