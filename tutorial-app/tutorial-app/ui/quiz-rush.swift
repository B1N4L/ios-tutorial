//
//  quiz-rush.swift
//  tutorial-app
//
//  Created by Student 2 on 2026-06-30.
//

import SwiftUI

struct QuizRush: View {
    
    @State private var quizzes: [Quiz] = []
    @State private var viewState: QuizViewState = .idle
    @State private var currentQuestion = 0
    @State private var score: Double = 0
    @State private var selectedAnswer: String?
    @State private var shuffledAnswers: [String] = []
    @State private var isAnswerCorrect: Bool?
    @State private var scoreChange: Double = 0
    @State private var showScoreChange = false
    
    enum QuizViewState: Equatable {
        case idle
        case loading
        case playing
        case finished(score: Double)
        case error(String)
    }
    
    @MainActor
    func fetchQuizzes() async {
        guard let url = URL(
            string: "https://opentdb.com/api.php?amount=10&type=multiple"
        ) else {
            viewState = .error("Invalid URL")
            return
        }

        viewState = .loading

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(QuizResponse.self, from: data)
            
            quizzes = result.results
            currentQuestion = 0
            score = 0
            selectedAnswer = nil
            isAnswerCorrect = nil
            scoreChange = 0
            showScoreChange = false
            
            if !quizzes.isEmpty {
                shuffleAnswersForCurrentQuestion()
            }
            
            viewState = .playing

        } catch {
            viewState = .error(error.localizedDescription)
        }
    }
    
    func shuffleAnswersForCurrentQuestion() {
        guard currentQuestion < quizzes.count else { return }
        
        let quiz = quizzes[currentQuestion]
        var answers = quiz.incorrect_answers
        answers.append(quiz.correct_answer)
        shuffledAnswers = answers.shuffled()
        selectedAnswer = nil
        isAnswerCorrect = nil
        scoreChange = 0
        showScoreChange = false
    }
    
    func answerSelected(_ answer: String) {
        guard selectedAnswer == nil else { return }
        
        let quiz = quizzes[currentQuestion]
        selectedAnswer = answer
        let correct = answer == quiz.correct_answer
        isAnswerCorrect = correct
        
        if correct {
            scoreChange = 1.0
            score += 1.0
        } else {
            scoreChange = -0.5
            score = max(0, score - 0.5)
        }
        
        showScoreChange = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showScoreChange = false
            if currentQuestion + 1 < quizzes.count {
                currentQuestion += 1
                shuffleAnswersForCurrentQuestion()
            } else {
                viewState = .finished(score: score)
            }
        }
    }
    
    func getButtonColor(for answer: String) -> Color {
        guard let selectedAnswer = selectedAnswer else {
            return .blue
        }
        
        if answer == quizzes[currentQuestion].correct_answer {
            return .green
        } else if answer == selectedAnswer && answer != quizzes[currentQuestion].correct_answer {
            return .red
        } else {
            return .gray.opacity(0.3)
        }
    }
    
    func decodeHTML(_ string: String) -> String {
        let decoded = string.replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#039;", with: "'")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&auml;", with: "ä")
            .replacingOccurrences(of: "&Auml;", with: "Ä")
            .replacingOccurrences(of: "&ouml;", with: "ö")
            .replacingOccurrences(of: "&Ouml;", with: "Ö")
            .replacingOccurrences(of: "&uuml;", with: "ü")
            .replacingOccurrences(of: "&Uuml;", with: "Ü")
            .replacingOccurrences(of: "&szlig;", with: "ß")
            .replacingOccurrences(of: "&eacute;", with: "é")
            .replacingOccurrences(of: "&Eacute;", with: "É")
            .replacingOccurrences(of: "&rsquo;", with: "'")
            .replacingOccurrences(of: "&lsquo;", with: "'")
            .replacingOccurrences(of: "&rdquo;", with: "\"")
            .replacingOccurrences(of: "&ldquo;", with: "\"")
        return decoded
    }
    
    func getScoreDisplay() -> String {
        if score.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", score)
        } else {
            return String(format: "%.1f", score)
        }
    }

    var body: some View {
        VStack(spacing: 20) {

            // MARK: - Header (Reduced Height)
            HStack {
                // Removed "Quiz Rush" text
                
                VStack(alignment: .leading) {
                    Text("\(quizzes.count) Questions")
                        .font(.headline) // Reduced from .largeTitle
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Score")
                        .font(.caption) // Reduced from .headline
                        .foregroundStyle(.secondary)

                    HStack(spacing: 4) {
                        Text(getScoreDisplay())
                            .font(.title2) // Reduced from .largeTitle
                            .fontWeight(.bold)
                            .foregroundStyle(score >= 5 ? .green : score >= 3 ? .orange : .red)
                        
                        if showScoreChange {
                            Text(scoreChange > 0 ? "+1" : "-0.5")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(scoreChange > 0 ? .green : .red)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 20) // Reduced top padding
            .animation(.spring(response: 0.3), value: showScoreChange)

            // MARK: - Middle Section (Takes more space)
            Group {
                switch viewState {

                case .idle:
                    VStack(spacing: 16) {
                        Image(systemName: "play.circle")
                            .font(.system(size: 60))
                        Text("Press Start to begin")
                            .font(.title2)
                    }

                case .loading:
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("Loading quizzes...")
                            .font(.title2)
                    }

                case .playing:
                    VStack(alignment: .leading, spacing: 16) {
                        // Question progress with visual indicator
                        HStack {
                            Text("Question \(currentQuestion + 1) of \(quizzes.count)")
                                .font(.subheadline) // Reduced from .headline
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            // Progress dots
                            HStack(spacing: 4) {
                                ForEach(0..<quizzes.count, id: \.self) { index in
                                    Circle()
                                        .fill(index <= currentQuestion ? Color.blue : Color.gray.opacity(0.3))
                                        .frame(width: 6, height: 6) // Reduced from 8
                                }
                            }
                        }

                        Text(decodeHTML(quizzes[currentQuestion].question))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.vertical, 8)

                        // Answer buttons - now take up more space
                        VStack(spacing: 14) { // Increased spacing
                            ForEach(shuffledAnswers, id: \.self) { answer in
                                Button {
                                    answerSelected(answer)
                                } label: {
                                    Text(decodeHTML(answer))
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16) // Increased vertical padding
                                        .padding(.horizontal)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(getButtonColor(for: answer))
                                                .opacity(selectedAnswer != nil ? 0.8 : 1.0)
                                        )
                                        .foregroundStyle(.white)
                                }
                                .disabled(selectedAnswer != nil)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        // Show correct/incorrect indicator with points
                        if let isCorrect = isAnswerCorrect {
                            HStack {
                                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(isCorrect ? .green : .red)
                                Text(isCorrect ? "Correct! +1 point ✓" : "Wrong! -0.5 points ✗")
                                    .font(.headline)
                                    .foregroundStyle(isCorrect ? .green : .red)
                            }
                            .padding(.top, 4)
                            .transition(.opacity)
                        }
                        
                        Spacer(minLength: 0) // Pushes content to fill available space
                    }

                case .finished(let finalScore):
                    VStack(spacing: 20) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.yellow)

                        Text("Game Over")
                            .font(.largeTitle)

                        HStack(spacing: 4) {
                            Text("Final Score: \(String(format: "%.1f", finalScore))")
                                .font(.title)
                            
                            if finalScore.truncatingRemainder(dividingBy: 1) == 0 {
                                Text("/ \(quizzes.count)")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        let percentage = finalScore / Double(quizzes.count)
                        if percentage >= 0.8 {
                            Text("Excellent! 🌟")
                                .font(.title2)
                                .foregroundStyle(.green)
                        } else if percentage >= 0.6 {
                            Text("Good job! 👍")
                                .font(.title2)
                                .foregroundStyle(.blue)
                        } else if percentage >= 0.4 {
                            Text("Keep practicing! 💪")
                                .font(.title2)
                                .foregroundStyle(.orange)
                        } else {
                            Text("Don't give up! Try again 🔄")
                                .font(.title2)
                                .foregroundStyle(.red)
                        }
                        
                        VStack(spacing: 4) {
                            Text("Scoring: +1 for correct, -0.5 for wrong")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("Minimum score: 0")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 10)
                        
                        Spacer(minLength: 0)
                    }

                case .error(let message):
                    VStack(spacing: 20) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundStyle(.red)

                        Text("Unable to load quizzes")
                            .font(.title2)

                        Text(message)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal)

            // MARK: - Footer (Reduced Height)
            HStack(spacing: 20) { // Reduced spacing from 30
                Button("Start") {
                    Task {
                        await fetchQuizzes()
                    }
                }
                .font(.title3) // Reduced from .title2
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10) // Reduced vertical padding
                .padding(.horizontal)
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(viewState == .loading)
                
                Button("Restart") {
                    quizzes.removeAll()
                    currentQuestion = 0
                    score = 0
                    selectedAnswer = nil
                    shuffledAnswers = []
                    isAnswerCorrect = nil
                    scoreChange = 0
                    showScoreChange = false
                    viewState = .idle
                }
                .font(.title3) // Reduced from .title2
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10) // Reduced vertical padding
                .padding(.horizontal)
                .buttonStyle(.bordered)
                .tint(.red)
            }
            .padding(.horizontal)
            .padding(.bottom, 16) // Reduced bottom padding
        }
        .padding(.vertical, 20) // Reduced overall vertical padding from 40
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
