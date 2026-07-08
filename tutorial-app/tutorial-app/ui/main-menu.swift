import SwiftUI
import Combine

struct MainMenu: View {
    @State private var score = 0
    @State private var timeLeft = 10
    @State private var isGameActive = false

    enum Game: Hashable {
        case tapFrenzy
        case lightItUp
        case quizRush
        case highScores
        case mapView // <-- NEW CASE
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
                
                Button(action: { navigateToGame(.quizRush) }) {
                    Text("Quiz Rush")
                }
                
                Button(action: { navigateToGame(.highScores) }) {
                    Text("High Scores")
                }
                
                // --- NEW MAP BUTTON ---
                Button(action: { navigateToGame(.mapView) }) {
                    Text("Show Static Map")
                }
                // ------------------------

                Button(action: { /* Exit behavior */ }) {
                    Text("Exit")
                }
            }
            .padding()
            .navigationTitle("Games")
            .navigationDestination(for: Game.self) { game in
                switch game {
                case .tapFrenzy:
                    TapFrenzyView()
                case .lightItUp:
                    LightItUpView()
                case .quizRush:
                    QuizRushView()
                case .highScores:
                    HighScoresView()
                case .mapView: // <-- NEW DESTINATION
                    MapKitView()
                        .navigationTitle("My Map") // Optional: add a title for this screen
                }
            }
        }
    }
    
    private func navigateToGame(_ game: Game) {
        path.append(game)
    }
}
