//
//  PersistenceController.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation
import SwiftData

/// Central place that defines the SwiftData schema and builds `ModelContainer`s.
/// The app uses the on-disk container; tests use `inMemory()` for isolation.
enum PersistenceController {
    /// Every `@Model` type in the app. Add new models here as phases introduce them.
    static let schema = Schema([
        PostEntity.self
    ])

    static func makeContainer(inMemory: Bool = false) -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
