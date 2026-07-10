import SwiftUI
import Charts

struct HighScoresView: View {
    @StateObject private var vm = StatsVM()

    var body: some View {
        NavigationView {
            if !vm.hasScores {
                emptyStateView
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // MARK: - Totals Section
                        totalsSection

                        // MARK: - Personal Bests Section
                        personalBestsSection

                        // MARK: - Bar Chart
                        barChartSection

                        // MARK: - Recent Games
                        recentGamesSection
                    }
                    .padding()
                }
                .navigationTitle("Stats")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Refresh") {
                            vm.load()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Subviews
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            Text("No scores yet")
                .font(.title2)
                .foregroundColor(.secondary)
            Text("Play a game to set a record!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var totalsSection: some View {
        HStack(spacing: 16) {
            StatCard(title: "Games", value: "\(vm.totalGames)", icon: "gamecontroller.fill", color: .blue)
            StatCard(title: "Total Score", value: vm.totalScore.formatted(.number.precision(.fractionLength(0))), icon: "sum", color: .orange)
        }
    }

    private var personalBestsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Personal Bests")
                .font(.title2.bold())

            ForEach(vm.bestScoresByMode, id: \.mode) { item in
                HStack {
                    Label(item.mode.rawValue.capitalized, systemImage: modeIcon(for: item.mode))
                        .font(.headline)
                    Spacer()
                    Text("\(item.best, format: .number.precision(.fractionLength(0)))")
                        .font(.title3.bold())
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var barChartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Best Score per Mode")
                .font(.title2.bold())

            Chart(vm.chartData) { item in
                BarMark(
                    x: .value("Mode", item.mode),
                    y: .value("Best Score", item.bestScore)
                )
                .foregroundStyle(by: .value("Mode", item.mode))
            }
            .frame(height: 200)
            .chartYAxisLabel("Score")
        }
    }

    private var recentGamesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Games")
                .font(.title2.bold())

            ForEach(vm.recentSessions) { session in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.mode.rawValue.capitalized)
                            .font(.subheadline.bold())
                        Text(session.timestamp, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("\(session.score, format: .number.precision(.fractionLength(0)))")
                        .font(.headline)
                }
                .padding(.vertical, 4)
                Divider()
            }
        }
    }

    // Helper to pick an SF Symbol per mode
    private func modeIcon(for mode: GameMode) -> String {
        switch mode {
        case .tapFrenzy: return "hand.tap.fill"
        case .quizRush: return "brain.head.profile"
        case .lightItUp: return "lightbulb.fill"
        }
    }
}

// MARK: - Reusable Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.caption.bold())
                .foregroundColor(.secondary)
            Text(value)
                .font(.largeTitle.bold())
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    HighScoresView()
}
