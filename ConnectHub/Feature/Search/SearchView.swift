//
//  SearchView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Search tab root. Debounced user/post search and recent searches arrive in
/// Phase 5.
struct SearchView: View {
    var body: some View {
        PlaceholderScreen(systemImage: "magnifyingglass", title: "Search",
                          phase: "Coming in Phase 5")
            .navigationTitle("Search")
    }
}
