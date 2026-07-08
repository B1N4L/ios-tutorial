//
//  TapFrenzyView.swift
//  tutorial-app
//
//  Created by Student 2 on 2026-07-08.
//

import SwiftUI

struct TapFrenzyView: View {
    @StateObject private var vm = TapFrenzyVM()

    var body: some View {
        VStack(spacing: 40) {
            // Header: Score + Multiplier + Timer
            HStack {
                VStack(alignment: .leading) {
                    Text("Score")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(vm.score, format: .number.precision(.fractionLength(0)))
                            .font(.system(size: 48, weight: .bold))

                        if vm.multiplier > 1 {
                            Text("x\(vm.multiplier)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.orange)
                                .transition(.scale.combined(with: .opacity))
//                                .modifier(ShakeEffect(animatableData: vm.multiplierShakeTrigger))
                        }
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Time")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("\(vm.timeLeft)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(vm.timeLeft > 3 ? .primary : .red)
                }
            }
            .padding(.horizontal)

            Spacer()

            // Main game area
            GeometryReader { geometry in
                HStack {
                    Button(action: vm.tapButton) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: vm.buttonSize, height: vm.buttonSize)
                                .shadow(radius: 15)

                            Text("TAP!")
                                .font(.system(size: vm.buttonFontSize, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!vm.isGameActive)
                    .scaleEffect(vm.isGameActive ? 1.0 : 0.95)
                    .animation(.spring(response: 0.3), value: vm.isGameActive)
                    .position(vm.circlePosition)
                    .onAppear {
                        vm.screenSize = geometry.size
                        // Center the button initially (only if not already set)
                        if vm.circlePosition == .zero {
                            vm.circlePosition = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        }
                    }
                    .onChange(of: geometry.size) { _, newSize in
                        vm.screenSize = newSize
                    }
                }
            }
            .padding(.horizontal, 100)

            Spacer()

            // Control Buttons
            if !vm.isGameActive {
                Button("Start") { vm.startGame() }
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
            } else {
                Button("Restart") { vm.restartGame() }
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 40)
        .alert("Game Over", isPresented: $vm.showGameOverAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your score: \(vm.finalScore, format: .number.precision(.fractionLength(0)))")
        }
    }
}
