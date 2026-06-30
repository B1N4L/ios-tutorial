//
//  quiz-rush.swift
//  tutorial-app
//
//  Created by Student 2 on 2026-06-30.
//


import SwiftUI

struct QuizRush: View {
    
    @State private var quizzes: [Quiz] = []
    @State private var isLoading = false
    
    @MainActor
    func fetchQuizzes() async {

        guard let url = URL(
            string: "https://opentdb.com/api.php?amount=10&type=multiple"
        ) else {
            return
        }
        isLoading = true

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(QuizResponse.self, from: data)
            quizzes = result.results
        } catch {
            print(error)
        }
        isLoading = false
    }

    var body: some View {
        VStack(spacing: 40) {

            // MARK: - Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Header Left")
                        .font(.headline)

                    Text("Content")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Header Right")
                        .font(.headline)

                    Text("Content")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
            }
            .padding(.horizontal)

            Spacer()

            // MARK: - Middle Section: quiz list go brrrr
                HStack {
                    Spacer()
                    List(quizzes) { quiz in
                        VStack(alignment: .leading, spacing: 8) {

                            Text(quiz.question)
                                .font(.headline)

                            Text("Answer: \(quiz.correct_answer)")
                                .foregroundColor(.green)
                        }
                    }

                    Spacer()
                }


            // MARK: - Footer
            HStack(spacing: 30) {

                Button("Start") {
                    Task { await fetchQuizzes() }
                }
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                Button("Restart") {
                    quizzes.removeAll()
                }
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
}




struct QuizResponse: Decodable {
    let response_code: Int
    let results: [Quiz]
}

struct Quiz: Decodable, Identifiable {
    let id = UUID()

    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]

    enum CodingKeys: String, CodingKey {
        case category
        case type
        case difficulty
        case question
        case correct_answer
        case incorrect_answers
    }
}

#Preview {
    QuizRush()
}
