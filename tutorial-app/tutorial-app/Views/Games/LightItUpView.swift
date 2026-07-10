import SwiftUI

struct LightItUpView: View {
    @StateObject private var vm = LightItUpVM()
    @State private var showHighScores = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Header
                HStack {
                    if vm.isGameActive {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Time: \(vm.timeLeft)")
                                .font(.title2).fontWeight(.bold)
                            Text("Level: \(vm.currentLevel.rawValue)")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    // Hearts (lives)
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { index in
                            Image(systemName: index < vm.lives ? "heart.fill" : "heart")
                                .foregroundColor(.red).font(.title2)
                        }
                    }

                    Spacer()

                    if vm.isGameActive {
                        Text("Score: \(vm.score)")
                            .font(.largeTitle).fontWeight(.bold)
                    }

                    if !vm.isGameActive {
                        Button {
                            showHighScores = true
                        } label: {
                            Text("Scoreboard")
                                .font(.headline).fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16).padding(.vertical, 10)
                        }
                        .background(Color.black)
                        .cornerRadius(12)
                        .padding(.leading, 4)
                    }
                }
                .padding()

                // Grid / Placeholder
                VStack {
                    if vm.isGameActive {
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                            spacing: 10
                        ) {
                            ForEach(0..<vm.tileCount, id: \.self) { index in
                                TileView(
                                    isLit: vm.currentLitTile == index,
                                    glowColor: vm.glowColor(for: vm.currentLevel)
                                )
                                .onTapGesture {
                                    vm.tileTapped(index)
                                }
                            }
                        }
                        .padding()
                    } else {
                        VStack(spacing: 16) {
                            Text("Light It Up").font(.largeTitle).foregroundColor(.black)
                            Image(systemName: "hand.tap.fill").font(.system(size: 60)).foregroundColor(.gray)
                            Text("Press Start to Begin").font(.title3).foregroundColor(.gray)
                        }
                    }
                }
                .frame(maxHeight: .infinity)

                // Control Buttons
                HStack(spacing: 20) {
                    if !vm.isGameActive {
                        Button("Start") { vm.startGame() }
                            .font(.headline).fontWeight(.semibold)
                            .frame(maxWidth: .infinity).padding()
                            .foregroundColor(.white)
                            .background(Color.black).cornerRadius(12)
                    } else {
                        Button("Stop") { vm.stopGame() }
                            .font(.headline).fontWeight(.semibold)
                            .frame(maxWidth: .infinity).padding()
                            .foregroundColor(.white)
                            .background(Color.black).cornerRadius(12)
                    }
                }
                .padding(.horizontal)

                if !vm.isGameActive && vm.finalScore > 0 {
                    ShareLink(item: GameSession.shareMessage(score: Double(vm.finalScore), mode: .lightItUp)) {
                        Label("Share Score", systemImage: "square.and.arrow.up")
                            .font(.headline)
                    }
                    .padding(.bottom)
                }
            }

            // Level-up overlay
            if vm.showLevelUp {
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        VStack(spacing: 20) {
                            Text("LEVEL UP!")
                                .font(.system(size: 50, weight: .heavy)).foregroundColor(.white)
                            Text(vm.levelUpText)
                                .font(.largeTitle).foregroundColor(.yellow)
                        }
                    )
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .alert("Game Over", isPresented: $vm.showGameOverAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your score: \(vm.finalScore)")
        }
        .sheet(isPresented: $showHighScores) {
            HighScoresView()
        }
    }
}

// Tile subview (unchanged)
struct TileView: View {
    let isLit: Bool
    let glowColor: Color

    var body: some View {
        Rectangle()
            .fill(isLit ? Color.white : Color.black)
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 2)
            )
            .shadow(color: isLit ? glowColor.opacity(0.8) : .clear, radius: isLit ? 10 : 0)
    }
}
