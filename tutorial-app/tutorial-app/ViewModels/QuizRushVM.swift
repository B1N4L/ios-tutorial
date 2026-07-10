import SwiftUI
import Combine
import CoreLocation

@MainActor
class QuizRushVM: ObservableObject {
    // MARK: - Published State
    @Published var quizzes: [Quiz] = []
    @Published var viewState: QuizViewState = .idle
    @Published var currentQuestionIndex = 0
    @Published var score: Double = 0
    @Published var selectedAnswer: String?
    @Published var shuffledAnswers: [String] = []
    @Published var isAnswerCorrect: Bool?
    @Published var scoreChange: Double = 0
    @Published var showScoreChange = false

    // MARK: - Dependencies
    private let apiService: APIServiceProtocol
    private let highScoreService: HighScoreServiceProtocol
    private let locationService: LocationServiceProtocol

    // MARK: - Initialization
    init(apiService: APIServiceProtocol? = nil,
         highScoreService: HighScoreServiceProtocol? = nil,
         locationService: LocationServiceProtocol? = nil) {
        self.apiService = apiService ?? APIService()
        self.highScoreService = highScoreService ?? HighScoreService.shared
        self.locationService = locationService ?? LocationService.shared
    }

    // MARK: - State Enum
    enum QuizViewState: Equatable {
        case idle
        case loading
        case playing
        case finished(score: Double)
        case error(String)
    }

    // MARK: - Computed Properties for Button Visibility
    var shouldShowStartButton: Bool {
        if case .idle = viewState { return true }
        if case .error = viewState { return true }
        return false
    }

    var shouldShowRestartButton: Bool {
        if case .finished = viewState { return true }
        if case .error = viewState { return true }
        return false
    }

    var shouldShowFooter: Bool {
        if case .idle = viewState { return true }
        if case .error = viewState { return true }
        if case .finished = viewState { return true }
        return false
    }

    // MARK: - Public Methods
    func startGame() async {
        viewState = .loading
        do {
            let fetchedQuizzes = try await apiService.fetchQuizzes(amount: 10)
            quizzes = fetchedQuizzes
            currentQuestionIndex = 0
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

    func restartGame() {
        quizzes.removeAll()
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        shuffledAnswers = []
        isAnswerCorrect = nil
        scoreChange = 0
        showScoreChange = false
        viewState = .idle
    }

    func selectAnswer(_ answer: String) {
        guard selectedAnswer == nil else { return }
        guard currentQuestionIndex < quizzes.count else { return }
        
        let quiz = quizzes[currentQuestionIndex]
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

        // Advance after delay
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 sec
            showScoreChange = false
            if currentQuestionIndex + 1 < quizzes.count {
                currentQuestionIndex += 1
                shuffleAnswersForCurrentQuestion()
            } else {
                // ✅ Save the score to the high‑score manager
                saveHighScore()
                viewState = .finished(score: score)
            }
        }
    }

    // MARK: - High Score Saving
    private func saveHighScore() {
        let coordinate = locationService.currentCoordinate
        let session = GameSession(score: score, mode: .quizRush,
                                  latitude: coordinate?.latitude ?? 0.0,
                                  longitude: coordinate?.longitude ?? 0.0)
        highScoreService.save(session)
    }

    // TODO: Move these to utils if convenient.
    // MARK: - Helpers
    private func shuffleAnswersForCurrentQuestion() {
        guard currentQuestionIndex < quizzes.count else { return }
        let quiz = quizzes[currentQuestionIndex]
        var answers = quiz.incorrect_answers
        answers.append(quiz.correct_answer)
        shuffledAnswers = answers.shuffled()
        selectedAnswer = nil
        isAnswerCorrect = nil
        scoreChange = 0
        showScoreChange = false
    }

    func getButtonColor(for answer: String) -> Color {
        guard let selectedAnswer = selectedAnswer else {
            return .blue
        }
        guard currentQuestionIndex < quizzes.count else { return .gray }
        let quiz = quizzes[currentQuestionIndex]
        if answer == quiz.correct_answer {
            return .green
        } else if answer == selectedAnswer && answer != quiz.correct_answer {
            return .red
        } else {
            return .gray.opacity(0.3)
        }
    }

    func getScoreDisplay() -> String {
        if score.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", score)
        } else {
            return String(format: "%.1f", score)
        }
    }

    func decodeHTML(_ string: String) -> String {
        // Same decoding logic as before
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
}
