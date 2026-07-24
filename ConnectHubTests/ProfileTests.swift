//
//  ProfileTests.swift
//  ConnectHubTests
//
//  Created by BitFuse on 24/07/2026.
//

import Testing
import Foundation
@testable import ConnectHub

@MainActor
struct ProfileRepositoryTests {

    @Test func currentProfileSeedsFromSession() {
        let session = makeEphemeralSessionRepository()
        session.save(Session(userId: "u9", displayName: "Grace", email: "g@navy.mil", token: "t"))
        let repo = DefaultProfileRepository(sessionRepository: session, defaults: makeEphemeralDefaults())

        let profile = repo.currentProfile()

        #expect(profile.id == "u9")
        #expect(profile.name == "Grace")
    }

    @Test func updateProfilePersistsAndEmits() async {
        let session = makeEphemeralSessionRepository()
        session.save(.sample())
        let repo = DefaultProfileRepository(sessionRepository: session, defaults: makeEphemeralDefaults())

        repo.updateProfile(name: "New Name", bio: "New bio", avatarURL: URL(string: "https://x.com/a.jpg"))

        #expect(repo.currentProfile().name == "New Name")
        #expect(repo.currentProfile().bio == "New bio")
        let observed = await firstValue(repo.observeProfile())
        #expect(observed?.name == "New Name")
    }

    @Test func updatesPersistAcrossInstances() {
        let session = makeEphemeralSessionRepository()
        session.save(.sample())
        let defaults = makeEphemeralDefaults()
        let writer = DefaultProfileRepository(sessionRepository: session, defaults: defaults)
        writer.updateProfile(name: "Persisted", bio: "b", avatarURL: nil)

        let reader = DefaultProfileRepository(sessionRepository: session, defaults: defaults)
        #expect(reader.currentProfile().name == "Persisted")
    }
}

@MainActor
struct EditProfileViewModelTests {

    private func makeViewModel(_ repo: StubProfileRepository) -> EditProfileViewModel {
        EditProfileViewModel(profile: repo.currentProfile(),
                             updateProfile: UpdateProfileUseCase(repository: repo))
    }

    @Test func prefillsFromProfile() {
        let repo = StubProfileRepository()
        repo.profile = User(id: "u", name: "Ada", avatarURL: URL(string: "https://x.com/a.jpg"),
                            bio: "Bio", followersCount: 1, followingCount: 2)
        let model = makeViewModel(repo)
        #expect(model.name == "Ada")
        #expect(model.bio == "Bio")
        #expect(model.avatarURL == "https://x.com/a.jpg")
    }

    @Test func blankNameBlocksSave() {
        let repo = StubProfileRepository()
        let model = makeViewModel(repo)
        model.name = ""
        #expect(model.save() == false)
        #expect(model.nameError != nil)
        #expect(repo.updates.isEmpty)
    }

    @Test func invalidAvatarURLBlocksSave() {
        let repo = StubProfileRepository()
        let model = makeViewModel(repo)
        model.name = "Ada"
        model.avatarURL = "not a url"
        #expect(model.save() == false)
        #expect(model.avatarURLError != nil)
        #expect(repo.updates.isEmpty)
    }

    @Test func validSaveTrimsAndPersists() {
        let repo = StubProfileRepository()
        let model = makeViewModel(repo)
        model.name = "  Ada Lovelace  "
        model.bio = "Enchantress of numbers"
        model.avatarURL = ""

        #expect(model.save() == true)
        #expect(repo.updates.count == 1)
        #expect(repo.updates.first?.name == "Ada Lovelace")
        #expect(repo.updates.first?.avatarURL == nil)
    }
}
