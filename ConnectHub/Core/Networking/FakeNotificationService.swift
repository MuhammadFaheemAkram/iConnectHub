//
//  FakeNotificationService.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Fake `NotificationService`: serves bundled notifications, newest first.
struct FakeNotificationService: NotificationService {
    private let shouldThrowError = false
    private let latency: Duration = .milliseconds(500)

    func notifications() async throws -> [NotificationDTO] {
        try await Task.sleep(for: latency)
        if shouldThrowError { throw AppError.network }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let dtos = (try? BundleJSON.decode([NotificationDTO].self, from: "notifications", decoder: decoder)) ?? []
        return dtos.sorted { $0.createdAt > $1.createdAt }
    }
}
