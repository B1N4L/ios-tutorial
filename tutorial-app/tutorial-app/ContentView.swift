import SwiftUI

struct ContentView: View {
    @State private var score = 0
    @State private var timeLeft = 10
    @State private var isGameActive = false
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 50) {
            // Header: Score and Timer
            HStack {
                VStack(alignment: .leading) {
                    Text("Score")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("\(score)")
                        .font(.system(size: 48, weight: .bold))
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Time")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("\(timeLeft)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(timeLeft > 3 ? .primary : .red)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Big Tap Button
            Button(action: tapButtonPressed) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 280, height: 280)
                        .shadow(radius: 15)
                    
                    Text("TAP!")
                        .font(.system(size: 60, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!isGameActive)
            .scaleEffect(isGameActive ? 1.0 : 0.95)
            .animation(.spring(response: 0.3), value: isGameActive)
            
            Spacer()
            
            // Control Buttons
            HStack(spacing: 30) {
                Button(action: startGame) {
                    Text("Start")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(isGameActive)
                
                Button(action: resetGame) {
                    Text("Restart")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
    
    private func tapButtonPressed() {
        guard isGameActive else { return }
        withAnimation(.easeInOut(duration: 0.1)) {
            score += 1
        }
    }
    
    private func startGame() {
        resetGame()
        
        isGameActive = true
        score = 0
        timeLeft = 10
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                if self.timeLeft > 0 {
                    self.timeLeft -= 1
                } else {
                    self.endGame()
                }
            }
        }
    }
    
    private func endGame() {
        timer?.invalidate()
        timer = nil
        isGameActive = false
    }
    
    private func resetGame() {
        timer?.invalidate()
        timer = nil
        score = 0
        timeLeft = 10
        isGameActive = false
    }
}

#Preview {
    ContentView()
}
