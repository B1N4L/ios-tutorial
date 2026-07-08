import SwiftUI
import Combine

// TODO: REFACTOR TO PURE FUNCTIONS TO CREATE UTILS IN NEXT INCREMENT

// MARK: - Shake Effect (used for multiplier tilt animation)
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8       // tilt angle in degrees
    var shakesPerUnit = 2
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let angle = amount * .pi / 180 * sin(animatableData * .pi * CGFloat(shakesPerUnit))
        return ProjectionTransform(CGAffineTransform(rotationAngle: angle))
    }
}

// MARK: - Game Mode
enum GameMode: String, Codable, CaseIterable {
    case tapFrenzy = "tap-frenzy"
}

// MARK: - High Score Record
struct HighScoreRecord: Identifiable, Codable {
    let id: UUID
    let mode: GameMode
    let score: Double          // supports decimals like 3.5
    let timestamp: Date
    let latitude: Double
    let longitude: Double

    init(score: Double, mode: GameMode = .tapFrenzy,
         latitude: Double = 0.0, longitude: Double = 0.0) {
        self.id = UUID()
        self.mode = mode
        self.score = score
        self.timestamp = Date()
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - High Score Manager (TapFrenzy specific, persisted as JSON in UserDefaults)
class HighScoreManagerTapFrenzy {
    static let shared = HighScoreManagerTapFrenzy()
    private let key = "highScoresTapFrenzy"

    // Suggestion: For a more robust solution you could store the JSON in the app’s
    // Documents directory (e.g. via FileManager), which also simplifies iCloud sync.
    // For now we use UserDefaults for its simplicity.

    func saveScore(_ score: Double, mode: GameMode = .tapFrenzy) {
        var scores = loadScores()
        let newRecord = HighScoreRecord(score: score, mode: mode)
        scores.append(newRecord)
        persist(scores)
    }

    func loadScores() -> [HighScoreRecord] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let scores = try? JSONDecoder().decode([HighScoreRecord].self, from: data) else {
            return []
        }
        return scores
    }

    func clearAllScores() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    private func persist(_ scores: [HighScoreRecord]) {
        if let data = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

// MARK: - Main Game View
struct TapFrenzy: View {
    @State private var score: Double = 0          // Double for internal precision, displayed as integer
    @State private var timeLeft = 10
    @State private var isGameActive = false

    // Combo System
    @State private var multiplier = 1
    @State private var comboStartedAt: Date? = nil

    // Random Button Positioning
    @State private var circlePosition: CGPoint = .zero
    @State private var screenSize: CGSize = .zero

    // Timer Publisher (modern method)
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    //Bonus burst
    @State private var bonusBurstActive: Bool = false

    // Button Size change
    @State private var buttonSize: CGFloat = 280
    //derived variable: didn't using a separate state to increase performance & memory
    private var buttonFontSize: CGFloat {
        buttonSize * 0.21
    }

    // Multiplier shake trigger
    @State private var multiplierShakeTrigger: CGFloat = 0

    // Game over popup
    @State private var showGameOverAlert = false
    @State private var finalScore: Double = 0

    var body: some View {
        VStack(spacing: 40) {
            // Header: Score + Multiplier + Timer(temporary)
            HStack {
                VStack(alignment: .leading) {
                    Text("Score")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        // Display score without decimal places
                        Text(score, format: .number.precision(.fractionLength(0)))
                            .font(.system(size: 48, weight: .bold))

                        if multiplier > 1 {
                            Text("x\(multiplier)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.orange)
                                .transition(.scale.combined(with: .opacity))
                                .modifier(ShakeEffect(animatableData: multiplierShakeTrigger))
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Time")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("\(timeLeft)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(timeLeft > 3 ? .primary : .red)
                }
            }
            .padding(.horizontal)

            Spacer()

            // Main Section
            GeometryReader { geometry in HStack {

                // Big Tap Button
                Button(action: tapButtonPressed) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: buttonSize, height: buttonSize) //decreasing button size
                            .shadow(radius: 15)

                        Text("TAP!")
                            .font(.system(size: buttonFontSize, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!isGameActive)
                .scaleEffect(isGameActive ? 1.0 : 0.95)
                .animation(.spring(response: 0.3), value: isGameActive)
                .position(circlePosition)
                .onAppear {
                    screenSize = geometry.size
                    // Place the button at the centre initially
                    circlePosition = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

                    Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                        if isGameActive {
                            placeCircleRandomly()
                        }
                    }
                }
                // Fixed: Modern onChange syntax (iOS 17+)
                .onChange(of: geometry.size) { _, newSize in
                    screenSize = newSize
                }

            }
            }.padding(.horizontal, 100)

            Spacer()

            // Control Buttons – show only the appropriate one
            if !isGameActive {
                Button("Start", action: startGame)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
            } else {
                Button("Restart", action: resetGame)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 40)

        // Timer using Timer.publish + onReceive
        .onReceive(timer) { _ in
            guard isGameActive && timeLeft > 0 else { return }

            timeLeft -= 1
            decreaseButtonSize()
            if timeLeft == 0 {
                endGame()
            }
        }

        // Game Over Alert (popup) – score shown as integer
        .alert("Game Over", isPresented: $showGameOverAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your score: \(finalScore, format: .number.precision(.fractionLength(0)))")
        }
    }

    private func tapButtonPressed() {
        guard isGameActive else { return }

        comboChange()

        // Add score with current multiplier – adds whole numbers, but kept as Double
        withAnimation(.easeInOut(duration: 0.1)) {
            score += Double(multiplier)
        }
    }

    // Combo Logic
    private func comboChange(){
        let now = Date()
        if let lastTime = comboStartedAt, now.timeIntervalSince(lastTime) <= 0.5 {
            multiplier += 1
            // Trigger shake/tilt animation when multiplier increases
            withAnimation(.linear(duration: 0.3)) {
                multiplierShakeTrigger += 1
            }
        } else {
            multiplier = 1
        }
        comboStartedAt = now
    }

    private func startGame() {
        resetGame()

        isGameActive = true
        score = 0
        timeLeft = 10
        multiplier = 1
        comboStartedAt = nil

        // Reset button to centre at game start
        if screenSize != .zero {
            circlePosition = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        }
    }

    private func endGame() {
        isGameActive = false
        finalScore = score
        showGameOverAlert = true

        // Save the current score using the renamed manager
        HighScoreManagerTapFrenzy.shared.saveScore(score, mode: .tapFrenzy)
    }

    private func resetGame() {
        score = 0
        timeLeft = 10
        multiplier = 1
        comboStartedAt = nil
        isGameActive = false
    }

    private func placeCircleRandomly() {
        guard screenSize.width > 0 && screenSize.height > 0 else { return }

        let radius: CGFloat = 30
        let randomX = CGFloat.random(in: radius...(screenSize.width - radius))
        let randomY = CGFloat.random(in: radius...(screenSize.height - radius))

        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            circlePosition = CGPoint(x: randomX, y: randomY)
        }

        print("middleSize: \(screenSize)")
        print("circlePosition: \(circlePosition)")
    }

    private func decreaseButtonSize() {
        let maxSize: CGFloat = 280
        let minSize: CGFloat = 80
        let progress = CGFloat(timeLeft) / 10.0
        buttonSize = minSize + (maxSize - minSize) * progress
    }

    private func triggerBonus() {
        //flash the button
        //change bonus state
        //double point count
    }
}

#Preview {
    TapFrenzy()
}
