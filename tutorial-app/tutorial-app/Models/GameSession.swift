//
//  GameSession.swift
//  tutorial-app
//
//  Created by Student 2 on 2026-07-08.
//

import Foundation

// MARK: - Game Session (used for high‑score storage)
struct GameSession: Identifiable, Codable {
    let id: UUID
    let mode: GameMode
    let score: Double          // stored with decimals, displayed as integer
    let timestamp: Date
    let latitude: Double
    let longitude: Double

    init(score: Double, mode: GameMode,
         latitude: Double = 0.0, longitude: Double = 0.0) {
        self.id = UUID()
        self.mode = mode
        self.score = score
        self.timestamp = Date()
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - High Score Manager (persisted in UserDefaults)
class HighScoreManager {
    static let shared = HighScoreManager()
    private let key = "gameSessions"   // all modes stored together

    func save(_ session: GameSession) {
        var sessions = loadAll()
        sessions.append(session)
        persist(sessions)
    }

    func loadAll() -> [GameSession] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let sessions = try? JSONDecoder().decode([GameSession].self, from: data) else {
            return []
        }
        return sessions
    }

    func clearAll() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    private func persist(_ sessions: [GameSession]) {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
