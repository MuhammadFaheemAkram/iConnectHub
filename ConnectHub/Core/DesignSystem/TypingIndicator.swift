//
//  TypingIndicator.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import SwiftUI

/// Animated three-dot "typing…" bubble shown while a reply is being generated.
struct TypingIndicator: View {
    @State private var animating = false

    var body: some View {
        HStack {
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .frame(width: 7, height: 7)
                        .foregroundStyle(CHColor.textSecondary)
                        .opacity(animating ? 1 : 0.3)
                        .animation(
                            .easeInOut(duration: 0.6).repeatForever().delay(Double(index) * 0.2),
                            value: animating
                        )
                }
            }
            .padding(.horizontal, CHSpacing.md)
            .padding(.vertical, CHSpacing.sm + 4)
            .background(CHColor.surface, in: RoundedRectangle(cornerRadius: CHRadius.lg, style: .continuous))
            Spacer(minLength: 48)
        }
        .onAppear { animating = true }
        .accessibilityLabel("Typing")
    }
}

#Preview {
    TypingIndicator().padding()
}
