//
//  StatsVM.swift
//  tutorial-app
//
//  Created by Binal Lokitha on 2026-07-17.
//

import SwiftUI

class StatsVM: ObservableObject {
    @Published private(set) var sessions: [GameSession] = []

    private let highScoreService: HighScoreServiceProtocol

    init(highScoreService: HighScoreServiceProtocol = HighScoreService.shared) {
        self.highScoreService = highScoreService
        load()
    }

    func load() {
        sessions = highScoreService.loadAll()
    }

    // MARK: - Derived statistics
    var hasScores: Bool { !sessions.isEmpty }

    var totalGames: Int { sessions.count }

    var totalScore: Double {
        sessions.reduce(0) { $0 + $1.score }
    }

    var bestScoresByMode: [(mode: GameMode, best: Double)] {
        Dictionary(grouping: sessions, by: { $0.mode })
            .map { mode, sessions in
                (mode: mode, best: sessions.map { $0.score }.max() ?? 0)
            }
            .sorted { $0.mode.rawValue < $1.mode.rawValue }
    }

    var recentSessions: [GameSession] {
        Array(sessions.sorted { $0.timestamp > $1.timestamp }.prefix(5))
    }

    var chartData: [BestScorePerMode] {
        bestScoresByMode.map {
            BestScorePerMode(mode: $0.mode.rawValue, bestScore: $0.best)
        }
    }

    struct BestScorePerMode: Identifiable {
        let id = UUID()
        let mode: String
        let bestScore: Double
    }
}
