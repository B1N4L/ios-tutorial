import SwiftUI
import Combine

class LightItUpVM: ObservableObject {
    @Published var score = 0
    @Published var timeLeft = 60
    @Published var isGameActive = false
    @Published var lives = 3
    @Published var tileCount = 3
    @Published var litWindowDuration: Double = 1.5
    @Published var currentLitTile: Int? = nil
    @Published var litTileExpiry: Date? = nil

    @Published var showGameOverAlert = false
    @Published var finalScore = 0

    @Published var showLevelUp = false
    @Published var levelUpText = ""

    private var previousLevel: GameLevel? = nil
    private var countdownCancellable: AnyCancellable?
    private var gameTickCancellable: AnyCancellable?

    // Levels – internal (default) so the view can access currentLevel and glowColor
    enum GameLevel: String {
        case L1, L2, L3, L4
    }

    var currentLevel: GameLevel {
        switch timeLeft {
        case 45...60: return .L1
        case 30...44: return .L2
        case 15...29: return .L3
        default:      return .L4
        }
    }

    func glowColor(for level: GameLevel) -> Color {
        switch level {
        case .L1: return .yellow
        case .L2: return .orange
        case .L3: return .red
        case .L4: return .purple
        }
    }

    // Start a new game
    func startGame() {
        score = 0
        timeLeft = 60
        lives = 3
        currentLitTile = nil
        litTileExpiry = nil
        isGameActive = true
        previousLevel = nil
        applyLevelSettings()
        spawnTile()

        countdownCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }

        gameTickCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.gameTick()
            }
    }

    // Stop the current game manually
    func stopGame() {
        guard isGameActive else { return }
        endGame()
    }

    private func tick() {
        guard isGameActive else { return }
        if timeLeft > 0 {
            timeLeft -= 1
            checkLevelChange()
            applyLevelSettings()
            if timeLeft == 0 {
                endGame()
            }
        }
    }

    private func gameTick() {
        guard isGameActive else { return }
        if let expiry = litTileExpiry, Date() >= expiry {
            currentLitTile = nil
            litTileExpiry = nil
        }
        if currentLitTile == nil {
            spawnTile()
        }
    }

    private func spawnTile() {
        guard isGameActive else { return }
        let randomIndex = Int.random(in: 0..<tileCount)
        currentLitTile = randomIndex
        litTileExpiry = Date().addingTimeInterval(litWindowDuration)
    }

    func tileTapped(_ index: Int) {
        guard isGameActive else { return }
        if currentLitTile != index {
            lives -= 1
            if lives <= 0 {
                endGame()
            }
            return
        }
        // Correct tile
        score += 1
        currentLitTile = nil
        litTileExpiry = nil
    }

    private func endGame() {
        isGameActive = false
        currentLitTile = nil
        litTileExpiry = nil
        finalScore = score
        showGameOverAlert = true
        countdownCancellable?.cancel()
        gameTickCancellable?.cancel()

        // Save to unified high score manager
        let session = GameSession(score: Double(score), mode: .lightItUp)
        HighScoreManager.shared.save(session)
    }

    private func applyLevelSettings() {
        switch currentLevel {
        case .L1:
            tileCount = 3
            litWindowDuration = 1.5
        case .L2:
            tileCount = 4
            litWindowDuration = 1.2
        case .L3:
            tileCount = 6
            litWindowDuration = 1.0
        case .L4:
            tileCount = 9
            litWindowDuration = 0.8
        }
    }

    private func checkLevelChange() {
        let newLevel = currentLevel
        if previousLevel != nil && previousLevel != newLevel {
            withAnimation(.easeInOut(duration: 0.5)) {
                showLevelUp = true
                levelUpText = newLevel.rawValue
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    self.showLevelUp = false
                }
            }
        }
        previousLevel = newLevel
    }
}
