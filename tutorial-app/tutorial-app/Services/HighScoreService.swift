//
//  HighScoreService.swift
//  tutorial-app
//
//  Created by Binal Lokitha on 2026-07-05.
//

import Foundation

protocol HighScoreServiceProtocol {
    func save(_ session: GameSession)
    func loadAll() -> [GameSession]
    func clearAll()
}

// Persists game sessions across all modes in UserDefaults.
final class HighScoreService: HighScoreServiceProtocol {
    static let shared = HighScoreService()

    private let defaults: UserDefaults
    private let key = "gameSessions"   // all modes stored together

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(_ session: GameSession) {
        var sessions = loadAll()
        sessions.append(session)
        persist(sessions)
    }

    func loadAll() -> [GameSession] {
        guard let data = defaults.data(forKey: key),
              let sessions = try? JSONDecoder().decode([GameSession].self, from: data) else {
            return []
        }
        return sessions
    }

    func clearAll() {
        defaults.removeObject(forKey: key)
    }

    private func persist(_ sessions: [GameSession]) {
        if let data = try? JSONEncoder().encode(sessions) {
            defaults.set(data, forKey: key)
        }
    }
}
