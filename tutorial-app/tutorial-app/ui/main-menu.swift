//
//  main-menu.swift
//  tutorial-app
//
//  Created by Student 2 on 2026-06-15.
//

import SwiftUI
import Combine

// TODO: REFACTOR TO PURE FUNCTIONS TO CREATE UTILS IN NEXT INCREMENT

struct MainMenu: View {
    @State private var score = 0
    @State private var timeLeft = 10
    @State private var isGameActive = false

    enum Game: Hashable {
        case tapFrenzy
        case lightItUp
        case quizRush
    }

    @State private var path: [Game] = []

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 16) {
                Text("Main Menu")
                    .font(.largeTitle)

                Button(action: { navigateToGame(.tapFrenzy) }) {
                    Text("Tap Frenzy")
                }

                Button(action: { navigateToGame(.lightItUp) }) {
                    Text("Light It Up")
                }

                Button(action: {navigateToGame(.quizRush) }) {
                    Text("Quiz Rush")
                }
                Button(action: { /* Exit behavior can be implemented as needed */ }) {
                    Text("Exit")
                }
            }
            .padding()
            .navigationTitle("Games")
            .navigationDestination(for: Game.self) { game in
                switch game {
                case .tapFrenzy:
                    TapFrenzy()
                case .lightItUp:
                    LightItUp()
                case .quizRush:
                    QuizRushView()
                }
                
            }
        }
    }
    
    private func navigateToGame(_ game: Game) {
        path.append(game)
    }
    
}
