//
//  EditProfileView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Edit Profile sheet: name, bio (with a counter), and avatar URL, validated and
/// persisted locally on save.
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var model: EditProfileViewModel

    init(environment: AppEnvironment) {
        _model = State(initialValue: environment.makeEditProfileViewModel())
    }

    var body: some View {
        @Bindable var model = model
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Your name", text: $model.name)
                        .textContentType(.name)
                    if let nameError = model.nameError {
                        errorText(nameError)
                    }
                }

                Section {
                    ZStack(alignment: .topLeading) {
                        if model.bio.isEmpty {
                            Text("Tell people about yourself")
                                .foregroundStyle(CHColor.textSecondary)
                                .padding(.top, 8)
                                .allowsHitTesting(false)
                        }
                        TextEditor(text: $model.bio)
                            .frame(minHeight: 96)
                            .scrollContentBackground(.hidden)
                    }
                } header: {
                    HStack {
                        Text("Bio")
                        Spacer()
                        Text("\(model.bioCount)/\(model.bioLimit)")
                            .foregroundStyle(model.isBioOverLimit ? CHColor.like : CHColor.textSecondary)
                    }
                }

                Section("Avatar URL") {
                    TextField("https://…", text: $model.avatarURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    if let avatarURLError = model.avatarURLError {
                        errorText(avatarURLError)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if model.save() { dismiss() }
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func errorText(_ message: String) -> some View {
        Text(message)
            .font(CHTypography.caption)
            .foregroundStyle(CHColor.like)
    }
}
