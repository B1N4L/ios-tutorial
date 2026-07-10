//
//  QuizRushView.swift
//  tutorial-app
//
//  Created by Student 2 on 2026-07-03.
//

import SwiftUI

struct QuizRushView: View {
    @StateObject private var viewModel = QuizRushVM()

    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Header
            headerView

            // MARK: - Main Content
            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // MARK: - Footer (Conditional)
            if viewModel.shouldShowFooter {
                footerView
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.vertical, 20)
        .animation(.easeInOut(duration: 0.3), value: viewModel.shouldShowFooter)
    }

    // MARK: - Subviews
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(viewModel.quizzes.count) Questions")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("Score")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    Text(viewModel.getScoreDisplay())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(viewModel.score >= 5 ? .green : viewModel.score >= 3 ? .orange : .red)

                    if viewModel.showScoreChange {
                        Text(viewModel.scoreChange > 0 ? "+1" : "-0.5")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(viewModel.scoreChange > 0 ? .green : .red)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .animation(.spring(response: 0.3), value: viewModel.showScoreChange)
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .idle:
            VStack(spacing: 16) {
                Text("Quiz Rush")
                    .font(.largeTitle)
                Image(systemName: "brain.fill")
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
            if viewModel.currentQuestionIndex < viewModel.quizzes.count {
                VStack(alignment: .leading, spacing: 16) {
                    // Progress
                    HStack {
                        Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.quizzes.count)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        HStack(spacing: 4) {
                            ForEach(0..<viewModel.quizzes.count, id: \.self) { index in
                                Circle()
                                    .fill(index <= viewModel.currentQuestionIndex ? Color.blue : Color.gray.opacity(0.3))
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }

                    Text(viewModel.decodeHTML(viewModel.quizzes[viewModel.currentQuestionIndex].question))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.vertical, 8)

                    // Answer buttons
                    VStack(spacing: 14) {
                        ForEach(viewModel.shuffledAnswers, id: \.self) { answer in
                            Button {
                                viewModel.selectAnswer(answer)
                            } label: {
                                Text(viewModel.decodeHTML(answer))
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .padding(.horizontal)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(viewModel.getButtonColor(for: answer))
                                            .opacity(viewModel.selectedAnswer != nil ? 0.8 : 1.0)
                                    )
                                    .foregroundStyle(.white)
                            }
                            .disabled(viewModel.selectedAnswer != nil)
                        }
                    }
                    .padding(.vertical, 4)

                    // Feedback
                    if let isCorrect = viewModel.isAnswerCorrect {
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

                    Spacer(minLength: 0)
                }
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
                        Text("/ \(viewModel.quizzes.count)")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }

                let percentage = finalScore / Double(viewModel.quizzes.count)
                if percentage >= 0.8 {
                    Text("Excellent!")
                        .font(.title2)
                        .foregroundStyle(.green)
                } else if percentage >= 0.6 {
                    Text("Good job!")
                        .font(.title2)
                        .foregroundStyle(.blue)
                } else if percentage >= 0.4 {
                    Text("Keep practicing!")
                        .font(.title2)
                        .foregroundStyle(.orange)
                } else {
                    Text("Don't give up! Try again")
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

                ShareLink(item: GameSession.shareMessage(score: finalScore, mode: .quizRush)) {
                    Label("Share Score", systemImage: "square.and.arrow.up")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)

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

    private var footerView: some View {
        HStack(spacing: 20) {
            if viewModel.shouldShowStartButton {
                Button("Start") {
                    Task {
                        await viewModel.startGame()
                    }
                }
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .padding(.horizontal)
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(viewModel.viewState == .loading)
            }

            if viewModel.shouldShowRestartButton {
                Button("Back") {
                    viewModel.restartGame()
                }
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .padding(.horizontal)
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
    }
}

#Preview {
    QuizRushView()
}
