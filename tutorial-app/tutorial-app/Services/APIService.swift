//
//  APIService.swift
//  tutorial-app
//
//  Created by Student 2 on 2026-07-03.
//

import Foundation

protocol APIServiceProtocol {
    func fetchQuizzes(amount: Int) async throws -> [Quiz]
}

class APIService: APIServiceProtocol {
    func fetchQuizzes(amount: Int = 10) async throws -> [Quiz] {
        guard let url = URL(string: "https://opentdb.com/api.php?amount=\(amount)&type=multiple") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(QuizResponse.self, from: data)
        return response.results
    }
}
