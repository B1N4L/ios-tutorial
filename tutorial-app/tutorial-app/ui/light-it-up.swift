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
    @State private var timeLeft = 10
    @State private var isGameActive = false
    
    // Only ONE tile is lit at a time
    @State private var currentLitTile: Int? = nil
    
    // Timer for game loop
    @State private var gameTimer: Timer?
    
    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Header
            VStack {
                Text("Score: \(score)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            
            // MARK: - Middle: 3x3 Grid
            VStack {
                Text("Light It Up")
                    .font(.title2)
                    .padding(.bottom, 8)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                    ForEach(0..<9, id: \.self) { index in
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
    }
    
    private func tileTapped(_ index: Int) {
        guard isGameActive, currentLitTile == index else { return }
        
        // Successful hit
        score += 1
        currentLitTile = nil  // Turn off the tile immediately
    }
    
    private func startGame() {
        isGameActive = true
        score = 0
        timeLeft = 10
        currentLitTile = nil
        
        startGameTimer()
    }
    
    private func stopGame() {
        isGameActive = false
        gameTimer?.invalidate()
        gameTimer = nil
        currentLitTile = nil
    }
    
    private func startGameTimer() {
        gameTimer?.invalidate()
        
        // Main game loop: light up a random tile every ~1.5 seconds
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            guard self.isGameActive else { return }
            
            // Randomly pick one tile (0-8)
            let randomIndex = Int.random(in: 0..<9)
            self.currentLitTile = randomIndex
            
            // Auto turn off after 1.2 seconds if not hit (gives player reaction window)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                if self.currentLitTile == randomIndex {
                    self.currentLitTile = nil
                }
            }
        }
    }
    
    
    
}

// MARK: - Tile View
struct TileView: View {
    let isLit: Bool
    
    var body: some View {
        Rectangle()
            .fill(isLit ? Color.yellow : Color.gray.opacity(0.3))
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black.opacity(0.7), lineWidth: 3)
            )
            .shadow(color: isLit ? .yellow.opacity(0.8) : .clear, radius: isLit ? 10 : 0)
    }
}

#Preview {
    LightItUp()
}
