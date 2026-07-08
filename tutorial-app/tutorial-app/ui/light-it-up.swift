////  light-it-up.swift
////  tutorial-app
////
////  Created by Student 2 on 2026-06-15.
////  test
//
//import SwiftUI
//import Combine
//
//// MARK: - High Score Model & Persistence
//struct HighScoreEntry: Codable, Identifiable, Equatable {
//    var id = UUID()
//    let name: String
//    let score: Int
//}
//
//struct HighScoreManagerLightItUp {
//    private static let key = "highScores"
//
//    static func load() -> [HighScoreEntry] {
//        guard let data = UserDefaults.standard.data(forKey: key),
//              let scores = try? JSONDecoder().decode([HighScoreEntry].self, from: data) else {
//            return []
//        }
//        return scores
//    }
//
//    static func save(_ scores: [HighScoreEntry]) {
//        if let data = try? JSONEncoder().encode(scores) {
//            UserDefaults.standard.set(data, forKey: key)
//        }
//    }
//}
//
//// MARK: - Main Game View
//struct LightItUp: View {
//    @State private var score = 0
//    @State private var timeLeft = 60
//    @State private var isGameActive = false
//
//    // Lives system
//    @State private var lives = 3
//
//    // Level-based game settings
//    @State private var tileCount = 3
//    @State private var litWindowDuration: Double = 1.5
//
//    // Only ONE tile is lit at a time
//    @State private var currentLitTile: Int? = nil
//    @State private var litTileExpiry: Date? = nil
//
//    // Timers
//    private let countDownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//    private let gameTickTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
//
//    // Level Progression
//    private enum GameLevel: String {
//        case L1, L2, L3, L4
//    }
//
//    // High scores state
//    @State private var highScores: [HighScoreEntry] = HighScoreManagerLightItUp.load()
//    @State private var showHighScoresList = false
//
//    // Game-over overlay
//    @State private var showGameOver = false
//    @State private var gameOverScore = 0
//    @State private var isHighScore = false
//
//    // Level‑up overlay
//    @State private var showLevelUp = false
//    @State private var levelUpText = ""
//    @State private var previousLevel: GameLevel? = nil
//
//    var body: some View {
//        ZStack {
//            // Main game content
//            VStack(spacing: 20) {
//                // MARK: - Header
//                HStack {
//                    // Time & Level – only visible during game
//                    if isGameActive {
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text("Time: \(timeLeft)")
//                                .font(.title2)
//                                .fontWeight(.bold)
//
//                            Text("Level: \(currentLevel.rawValue)")
//                                .font(.subheadline)
//                                .foregroundStyle(.secondary)
//                        }
//                    }
//
//                    Spacer()
//
//                    // Hearts (lives) – always visible
//                    HStack(spacing: 4) {
//                        ForEach(0..<3, id: \.self) { index in
//                            Image(systemName: index < lives ? "heart.fill" : "heart")
//                                .foregroundColor(.red)
//                                .font(.title2)
//                                .animation(.easeInOut(duration: 0.3), value: lives)
//                        }
//                    }
//
//                    Spacer()
//
//                    // Score – only visible during game
//                    if isGameActive {
//                        Text("Score: \(score)")
//                            .font(.largeTitle)
//                            .fontWeight(.bold)
//                    }
//
//                    // Trophy button – hidden while game is active
//                    if !isGameActive {
//                        Button {
//                            showHighScoresList = true
//                        } label: {
//                            Text("Scoreboard")
//                                .font(.headline)
//                                .fontWeight(.semibold)
//                                .foregroundColor(.white)
//                                .padding(.horizontal, 16)
//                                .padding(.vertical, 10)
//                        }
//                        .background(Color.black)
//                        .cornerRadius(12)                    // Curved edges
//                        .padding(.leading, 4)
//                    }
//                }
//                .padding()
//
//                // MARK: - Middle: Game Grid or Placeholder
//                VStack {
//                    if isGameActive {
//                        LazyVGrid(
//                            columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
//                            spacing: 10
//                        ) {
//                            ForEach(0..<tileCount, id: \.self) { index in
//                                TileView(
//                                    isLit: currentLitTile == index,
//                                    glowColor: glowColor(for: currentLevel)
//                                )
//                                .onTapGesture {
//                                    tileTapped(index)
//                                }
//                            }
//                        }
//                        .padding()
//                    } else {
//                        // Placeholder shown before the game starts / after it ends
//                        VStack(spacing: 16) {
//                            Text("Light It Up")
//                                .font(.largeTitle)
//                                .foregroundColor(.black)
//                            Image(systemName: "hand.tap.fill")
//                                .font(.system(size: 60))
//                                .foregroundColor(.gray)
//                            Text("Press Start to Begin")
//                                .font(.title3)
//                                .fontWeight(.light)
//                                .foregroundColor(.gray)
//                        }
//                    }
//                }
//                .frame(maxHeight: .infinity)
//
//                // MARK: - Footer: Start / Stop buttons (visibility managed)
//                HStack(spacing: 20) {
//                    if !isGameActive {
//                        Button(action: startGame) {
//                            Text("Start")
//                                .font(.headline)
//                                .fontWeight(.semibold)
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .foregroundColor(.white)
//                        }
//                        .background(Color.black)
//                        .cornerRadius(12)
//                    }
//                    
//                    if isGameActive {
//                        Button(action: stopGame) {
//                            Text("Stop")
//                                .font(.headline)
//                                .fontWeight(.semibold)
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .foregroundColor(.white)
//                        }
//                        .background(Color.black)
//                        .cornerRadius(12)
//                    }
//                }
//                .padding()
//            }
//
//            // Level‑up overlay (semi‑transparent, high z‑index)
//            if showLevelUp {
//                Color.black.opacity(0.6)
//                    .edgesIgnoringSafeArea(.all)
//                    .overlay(
//                        VStack(spacing: 20) {
//                            Text("LEVEL UP!")
//                                .font(.system(size: 50, weight: .heavy))
//                                .foregroundColor(.white)
//                                .shadow(radius: 10)
//                            Text(levelUpText)
//                                .font(.largeTitle)
//                                .foregroundColor(.yellow)
//                                .shadow(radius: 5)
//                        }
//                    )
//                    .transition(.opacity)
//                    .zIndex(1)
//            }
//        }
//        // High-scores sheet (trophy button)
//        .sheet(isPresented: $showHighScoresList) {
//            HighScoresListView(highScores: highScores)
//        }
//        // Game-over sheet (name entry)
//        .sheet(isPresented: $showGameOver) {
//            GameOverView(
//                score: gameOverScore,
//                isNewHighScore: isHighScore,
//                highScores: highScores
//            ) { name in
//                let entry = HighScoreEntry(name: name, score: gameOverScore)
//                var updated = highScores
//                updated.append(entry)
//                updated.sort { $0.score > $1.score }
//                updated = Array(updated.prefix(10))
//                highScores = updated
//                HighScoreManagerLightItUp.save(highScores)
//            }
//        }
//        .onReceive(countDownTimer) { _ in
//            guard isGameActive else { return }
//
//            if timeLeft > 0 {
//                timeLeft -= 1
//                applyLevelSettings()
//
//                if timeLeft == 0 {
//                    stopGame()
//                }
//            }
//        }
//        .onReceive(gameTickTimer) { _ in
//            guard isGameActive else { return }
//            gameTick()
//        }
//        .onChange(of: currentLevel) { newLevel in
//            // Trigger level‑up overlay when the level changes
//            if let prev = previousLevel, prev != newLevel {
//                withAnimation(.easeInOut(duration: 0.5)) {
//                    showLevelUp = true
//                    levelUpText = newLevel.rawValue
//                }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                    withAnimation(.easeInOut(duration: 0.5)) {
//                        showLevelUp = false
//                    }
//                }
//            }
//            previousLevel = newLevel
//        }
//    }
//
//    // MARK: - Game Logic Helpers
//
//    private var currentLevel: GameLevel {
//        switch timeLeft {
//        case 45...60: return .L1
//        case 30...44: return .L2
//        case 15...29: return .L3
//        default:      return .L4
//        }
//    }
//
//    private func glowColor(for level: GameLevel) -> Color {
//        switch level {
//        case .L1: return .yellow
//        case .L2: return .orange
//        case .L3: return .red
//        case .L4: return .purple
//        }
//    }
//
//    private func applyLevelSettings() {
//        switch currentLevel {
//        case .L1:
//            tileCount = 3
//            litWindowDuration = 1.5
//        case .L2:
//            tileCount = 4
//            litWindowDuration = 1.2
//        case .L3:
//            tileCount = 6
//            litWindowDuration = 1.0
//        case .L4:
//            tileCount = 9
//            litWindowDuration = 0.8
//        }
//    }
//
//    private func gameTick() {
//        if let expiry = litTileExpiry, Date() >= expiry {
//            currentLitTile = nil
//            litTileExpiry = nil
//        }
//
//        if currentLitTile == nil {
//            spawnTile()
//        }
//    }
//
//    private func spawnTile() {
//        guard isGameActive else { return }
//        let randomIndex = Int.random(in: 0..<tileCount)
//        currentLitTile = randomIndex
//        litTileExpiry = Date().addingTimeInterval(litWindowDuration)
//    }
//
//    private func tileTapped(_ index: Int) {
//        guard isGameActive else { return }
//
//        // Wrong tile → lose a life (no score penalty)
//        guard currentLitTile == index else {
//            withAnimation {
//                lives -= 1
//            }
//            if lives <= 0 {
//                stopGame()
//            }
//            return
//        }
//
//        // Correct tile
//        score += 1
//        currentLitTile = nil
//        litTileExpiry = nil
//    }
//
//    private func startGame() {
//        isGameActive = true
//        score = 0
//        timeLeft = 60
//        lives = 3
//        currentLitTile = nil
//        litTileExpiry = nil
//
//        // Reset level tracking
//        previousLevel = nil
//
//        applyLevelSettings()
//        spawnTile()
//    }
//
//    private func stopGame() {
//        guard isGameActive else { return }
//        isGameActive = false
//        currentLitTile = nil
//        litTileExpiry = nil
//
//        // Determine high score eligibility
//        let finalScore = score
//        gameOverScore = finalScore
//        isHighScore = highScores.count < 10 || finalScore > (highScores.last?.score ?? 0)
//        showGameOver = true
//    }
//}
//
//// MARK: - Tile View
//struct TileView: View {
//    let isLit: Bool
//    let glowColor: Color
//
//    var body: some View {
//        Rectangle()
//            .fill(isLit ? Color.white : Color.black)
//            .aspectRatio(1, contentMode: .fit)
//            .cornerRadius(12)
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(Color.gray, lineWidth: 2)
//            )
//            .shadow(
//                color: isLit ? glowColor.opacity(0.8) : .clear,
//                radius: isLit ? 10 : 0
//            )
//    }
//}
//
//// MARK: - High Scores List View
//struct HighScoresListView: View {
//    let highScores: [HighScoreEntry]
//
//    var body: some View {
//        NavigationView {
//            List {
//                if highScores.isEmpty {
//                    Text("No high scores yet.")
//                        .foregroundStyle(.secondary)
//                } else {
//                    ForEach(Array(highScores.enumerated()), id: \.element.id) { index, entry in
//                        HStack {
//                            Text("\(index + 1).")
//                                .fontWeight(.bold)
//                                .frame(width: 30, alignment: .leading)
//                            Text(entry.name)
//                            Spacer()
//                            Text("\(entry.score)")
//                                .fontWeight(.semibold)
//                        }
//                    }
//                }
//            }
//            .navigationTitle("High Scores")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Done") { /* dismiss handled by sheet */ }
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Game Over / Name Entry View
//struct GameOverView: View {
//    let score: Int
//    let isNewHighScore: Bool
//    let highScores: [HighScoreEntry]
//    var onSave: (String) -> Void
//
//    @Environment(\.dismiss) private var dismiss
//    @State private var playerName = ""
//
//    private var nameIsValid: Bool {
//        let trimmed = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
//        return (3...10).contains(trimmed.count)
//    }
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 24) {
//                Text("Game Over")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//
//                Text("Your score: \(score)")
//                    .font(.title2)
//
//                if isNewHighScore {
//                    Text("New high score!")
//                        .font(.headline)
//                        .foregroundStyle(.green)
//
//                    TextField("Enter your name (3-10 letters)", text: $playerName)
//                        .textFieldStyle(.roundedBorder)
//                        .padding(.horizontal)
//                        .onChange(of: playerName) { _ in
//                            if playerName.count > 10 {
//                                playerName = String(playerName.prefix(10))
//                            }
//                        }
//
//                    Button("Save Score") {
//                        let trimmed = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
//                        guard (3...10).contains(trimmed.count) else { return }
//                        onSave(trimmed)
//                        dismiss()
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .disabled(!nameIsValid)
//                } else {
//                    Text("Not a top‑10 score this time.")
//                        .foregroundStyle(.secondary)
//
//                    Button("Done") {
//                        dismiss()
//                    }
//                    .buttonStyle(.bordered)
//                }
//            }
//            .padding()
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .navigationBarHidden(true)
//        }
//    }
//}
//
//#Preview {
//    LightItUp()
//}
