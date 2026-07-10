//
//  ScoreBadge.swift
//  tutorial-app
//
//  Created by Binal Lokitha on 2026-07-17.
//

import SwiftUI

// Reusable capsule that displays a game score.
struct ScoreBadge: View {
    let score: Double

    var body: some View {
        Text(score, format: .number.precision(.fractionLength(0)))
            .font(.title2.bold())
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.accentColor.opacity(0.15)))
            .foregroundStyle(Color.accentColor)
    }
}

extension GameSession {
    // Shareable one-liner, e.g. "I just scored 47 on Quiz Rush — beat that".
    static func shareMessage(score: Double, mode: GameMode) -> String {
        let value = score.formatted(.number.precision(.fractionLength(0)))
        let name = mode.rawValue
            .split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
        return "I just scored \(value) on \(name) — beat that"
    }
}
