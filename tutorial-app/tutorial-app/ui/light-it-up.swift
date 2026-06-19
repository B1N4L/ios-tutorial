//
//  light-it-up.swift
//  tutorial-app
//
//  Created by Student 2 on 2026-06-15.
//

import SwiftUI
import Combine

struct LightItUp: View {
    @State private var score = 0
    @State private var timeLeft = 60
    @State private var isGameActive = false

    // Level-based game settings
    @State private var tileCount = 3
    @State private var litWindowDuration: Double = 1.5

    // Only ONE tile is lit at a time
    @State private var currentLitTile: Int? = nil
    @State private var litTileExpiry: Date? = nil

    // Timers
    private let countDownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let gameTickTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    // Level Progression
    private enum GameLevel: String {
        case L1, L2, L3, L4
    }

    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Time: \(timeLeft)")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Level: \(currentLevel.rawValue)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("Score: \(score)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding()
            
            // MARK: - Middle: Dynamic Grid
            VStack {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                    spacing: 10
                ) {
                    ForEach(0..<tileCount, id: \.self) { index in
                        TileView(isLit: currentLitTile == index)
                            .onTapGesture {
                                tileTapped(index)
                            }
                    }
                }
                .padding()
            }
            .frame(maxHeight: .infinity)
            
            // MARK: - Footer: Two Buttons
            HStack(spacing: 20) {
                Button(action: startGame) {
                    Text("Start")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: stopGame) {
                    Text("Stop")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .onReceive(countDownTimer) { _ in
            guard isGameActive else { return }

            if timeLeft > 0 {
                timeLeft -= 1
                applyLevelSettings()

                if timeLeft == 0 {
                    stopGame()
                }
            }
        }
        .onReceive(gameTickTimer) { _ in
            guard isGameActive else { return }
            gameTick()
        }
    }

    private var currentLevel: GameLevel {
        // Countdown is from 60 -> 0
        switch timeLeft {
        case 45...60:
            return .L1
        case 30...44:
            return .L2
        case 15...29:
            return .L3
        default:
            return .L4
        }
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

    private func gameTick() {
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

    private func tileTapped(_ index: Int) {
        guard isGameActive else { return }

        guard currentLitTile == index else {
            score -= 1
            return
        }

        score += 1
        currentLitTile = nil
        litTileExpiry = nil
    }
    
    private func startGame() {
        isGameActive = true
        score = 0
        timeLeft = 60
        currentLitTile = nil
        litTileExpiry = nil

        applyLevelSettings()
        spawnTile()
    }

    private func stopGame() {
        isGameActive = false
        currentLitTile = nil
        litTileExpiry = nil
    }
}

// MARK: - Tile View
struct TileView: View {
    let isLit: Bool
    var body: some View {
        Rectangle()
            .fill(isLit ? Color.white : Color.black)
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 2)
            )
            .shadow(
                color: isLit ? .white.opacity(0.8) : .clear,
                radius: isLit ? 10 : 0
            )
    }
}

#Preview {
    LightItUp()
}
