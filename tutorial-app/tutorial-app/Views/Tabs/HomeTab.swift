//
//  HomeTab.swift
//  tutorial-app
//
//  Created by Student 2 on 2026-07-08.
//

import SwiftUI

struct HomeTab: View {
    enum Game: Hashable {
        case tapFrenzy
        case lightItUp
        case quizRush
    }

    @State private var path: [Game] = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                gameRow(title: "Tap Frenzy",
                        subtitle: "Tap as fast as you can before time runs out",
                        icon: "hand.tap.fill",
                        color: .blue,
                        game: .tapFrenzy)

                gameRow(title: "Light It Up",
                        subtitle: "Hit the lit tile before it fades",
                        icon: "lightbulb.fill",
                        color: .orange,
                        game: .lightItUp)

                gameRow(title: "Quiz Rush",
                        subtitle: "Answer trivia against the clock",
                        icon: "brain.head.profile",
                        color: .purple,
                        game: .quizRush)
            }
            .navigationTitle("Games")
            .navigationDestination(for: Game.self) { game in
                switch game {
                case .tapFrenzy:
                    TapFrenzyView()
                        .navigationTitle("Tap Frenzy")
                        .navigationBarTitleDisplayMode(.inline)
                case .lightItUp:
                    LightItUpView()
                        .navigationTitle("Light It Up")
                        .navigationBarTitleDisplayMode(.inline)
                case .quizRush:
                    QuizRushView()
                        .navigationTitle("Quiz Rush")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }

    private func gameRow(title: String, subtitle: String, icon: String,
                         color: Color, game: Game) -> some View {
        Button {
            path.append(game)
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 6)
        }
    }
}
