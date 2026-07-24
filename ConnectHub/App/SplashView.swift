//
//  SplashView.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Branded launch screen shown while the saved session is being restored.
struct SplashView: View {
    var body: some View {
        ZStack {
            CHColor.brand.ignoresSafeArea()
            VStack(spacing: CHSpacing.lg) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(.white)
                Text("ConnectHub")
                    .font(CHTypography.largeTitle)
                    .foregroundStyle(.white)
                ProgressView()
                    .tint(.white)
                    .padding(.top, CHSpacing.sm)
            }
        }
    }
}

#Preview {
    SplashView()
}
