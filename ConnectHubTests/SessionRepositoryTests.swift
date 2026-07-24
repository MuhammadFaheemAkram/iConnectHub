//
//  SessionRepositoryTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
import Foundation
@testable import ConnectHub

@MainActor
struct SessionRepositoryTests {

    @Test func saveThenClearUpdatesCurrent() async {
        let repo = makeEphemeralSessionRepository()
        #expect(repo.current == nil)

        repo.save(.sample(userId: "u9"))
        #expect(repo.current?.userId == "u9")

        repo.clear()
        #expect(repo.current == nil)
    }

    @Test func restoreLoadsPreviouslyPersistedSession() async {
        let suite = "ConnectHubTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        // First repository persists a session.
        let writer = DefaultSessionRepository(store: SessionStore(defaults: defaults))
        writer.save(.sample(userId: "persisted"))

        // A fresh repository over the same store restores it.
        let reader = DefaultSessionRepository(store: SessionStore(defaults: defaults))
        #expect(reader.current == nil)
        await reader.restore()
        #expect(reader.current?.userId == "persisted")
    }

    @Test func streamEmitsCurrentThenEachChange() async {
        let repo = makeEphemeralSessionRepository()
        let stream = repo.sessions()

        // Collect the initial value plus two changes.
        let collector = Task { () -> [Session?] in
            var values: [Session?] = []
            for await session in stream {
                values.append(session)
                if values.count == 3 { break }
            }
            return values
        }

        repo.save(.sample(userId: "streamed"))
        repo.clear()

        let values = await collector.value
        #expect(values.count == 3)
        #expect(values[0] == nil)                    // emitted on subscribe
        #expect(values[1]?.userId == "streamed")     // after save
        #expect(values[2] == nil)                    // after clear
    }
}
