//
//  CreatePostView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Create Post sheet: a text editor with a live character counter, an optional
/// image URL, validation, and a fake submit that inserts the post into the feed
/// cache so it appears immediately.
struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var model: CreatePostViewModel

    init(environment: AppEnvironment) {
        _model = State(initialValue: environment.makeCreatePostViewModel())
    }

    var body: some View {
        @Bindable var model = model
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: CHSpacing.lg) {
                    editor(model: model)

                    HStack {
                        if let contentError = model.contentError {
                            Text(contentError)
                                .font(CHTypography.caption)
                                .foregroundStyle(CHColor.like)
                        }
                        Spacer()
                        Text("\(model.characterCount)/\(model.characterLimit)")
                            .font(CHTypography.captionStrong)
                            .foregroundStyle(model.isOverLimit ? CHColor.like : CHColor.textSecondary)
                            .contentTransition(.numericText())
                    }

                    CHTextField(title: "Image URL (optional)", text: $model.imageURL,
                                placeholder: "https://…",
                                systemImage: "photo",
                                error: model.imageURLError,
                                keyboard: .URL,
                                autocapitalization: .never)

                    if let generalError = model.generalError {
                        CHErrorBanner(message: generalError)
                    }
                }
                .padding(CHSpacing.lg)
            }
            .background(CHColor.groupedBackground)
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if model.isSubmitting {
                        ProgressView()
                    } else {
                        Button("Post") {
                            Task { if await model.submit() { dismiss() } }
                        }
                        .fontWeight(.semibold)
                        .disabled(model.isOverLimit)
                    }
                }
            }
        }
    }

    private func editor(model: CreatePostViewModel) -> some View {
        @Bindable var model = model
        return ZStack(alignment: .topLeading) {
            if model.content.isEmpty {
                Text("What's on your mind?")
                    .font(CHTypography.body)
                    .foregroundStyle(CHColor.textSecondary)
                    .padding(.top, 8)
                    .padding(.leading, 5)
                    .allowsHitTesting(false)
            }
            TextEditor(text: $model.content)
                .font(CHTypography.body)
                .frame(minHeight: 160)
                .scrollContentBackground(.hidden)
        }
    }
}
