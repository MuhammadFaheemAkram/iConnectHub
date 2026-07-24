//
//  EditProfileView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Edit Profile, presented from the Profile screen in Phase 5. Included now so
/// the feature module exists; Phase 5 adds the editable name/bio/avatar form.
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            PlaceholderScreen(systemImage: "pencil.circle", title: "Edit Profile",
                              phase: "Coming in Phase 5")
                .navigationTitle("Edit Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }
}
