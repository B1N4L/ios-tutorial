//
//  TapFrenzyVM.swift
//  tutorial-app
//
//  Created by Student 2 on 2026-07-08.
//

import SwiftUI
import Combine
import CoreLocation

class TapFrenzyVM: ObservableObject {
    // MARK: - Published state
    @Published var score: Double = 0
    @Published var timeLeft = 10
    @Published var isGameActive = false
    @Published var multiplier = 1
    @Published var circlePosition: CGPoint = .zero
    @Published var screenSize: CGSize = .zero
    @Published var buttonSize: CGFloat = 280
    @Published var multiplierShakeTrigger: CGFloat = 0
    @Published var showGameOverAlert = false
    @Published var finalScore: Double = 0

    var buttonFontSize: CGFloat { buttonSize * 0.21 }

    private var comboStartedAt: Date? = nil

    // Dependencies
    private let highScoreService: HighScoreServiceProtocol
    private let locationService: LocationServiceProtocol

    // Timer cancellables
    private var countdownCancellable: AnyCancellable?
    private var moveButtonCancellable: AnyCancellable?

    init(highScoreService: HighScoreServiceProtocol = HighScoreService.shared,
         locationService: LocationServiceProtocol = LocationService.shared) {
        self.highScoreService = highScoreService
        self.locationService = locationService
    }

    // MARK: - Actions
    func startGame() {
        resetGame()
        isGameActive = true
        score = 0
        timeLeft = 10
        multiplier = 1
        comboStartedAt = nil
        // Center the button
        if screenSize != .zero {
            circlePosition = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        }
        // Start countdown timer
        countdownCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
        // Start button movement timer (every 2 seconds)
        moveButtonCancellable = Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                if self?.isGameActive == true {
                    self?.placeCircleRandomly()
                }
            }
    }

    func restartGame() {
        // Just reset – the view will show the Start button again
        resetGame()
    }

    func tapButton() {
        guard isGameActive else { return }
        comboChange()
        withAnimation(.easeInOut(duration: 0.1)) {
            score += Double(multiplier)
        }
    }

    private func tick() {
        guard isGameActive && timeLeft > 0 else { return }
        timeLeft -= 1
        decreaseButtonSize()
        if timeLeft == 0 {
            endGame()
        }
    }

    private func endGame() {
        isGameActive = false
        finalScore = score
        showGameOverAlert = true
        countdownCancellable?.cancel()
        moveButtonCancellable?.cancel()

        // Save session using the high‑score service
        let coordinate = locationService.currentCoordinate
        let session = GameSession(score: score, mode: .tapFrenzy,
                                  latitude: coordinate?.latitude ?? 0.0,
                                  longitude: coordinate?.longitude ?? 0.0)
        highScoreService.save(session)
    }

    private func resetGame() {
        score = 0
        timeLeft = 10
        multiplier = 1
        comboStartedAt = nil
        isGameActive = false
        countdownCancellable?.cancel()
        moveButtonCancellable?.cancel()
    }

    // Combo logic
    private func comboChange() {
        let now = Date()
        if let lastTime = comboStartedAt, now.timeIntervalSince(lastTime) <= 0.5 {
            multiplier += 1
            withAnimation(.linear(duration: 0.3)) {
                multiplierShakeTrigger += 1
            }
        } else {
            multiplier = 1
        }
        comboStartedAt = now
    }

    func placeCircleRandomly() {
        guard screenSize.width > 0 && screenSize.height > 0 else { return }
        let radius: CGFloat = 30
        let randomX = CGFloat.random(in: radius...(screenSize.width - radius))
        let randomY = CGFloat.random(in: radius...(screenSize.height - radius))
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            circlePosition = CGPoint(x: randomX, y: randomY)
        }
    }

    private func decreaseButtonSize() {
        let maxSize: CGFloat = 280
        let minSize: CGFloat = 80
        let progress = CGFloat(timeLeft) / 10.0
        buttonSize = minSize + (maxSize - minSize) * progress
    }
}
