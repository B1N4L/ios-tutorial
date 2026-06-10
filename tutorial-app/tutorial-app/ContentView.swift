import SwiftUI

struct ContentView: View {
    @State private var score = 0
    @State private var timeLeft = 10
    @State private var isGameActive = false
    @State private var timer: Timer?
    
    // Combo System
    @State private var multiplier = 1
    @State private var lastTapTime: Date? = nil
    
    var body: some View {
        VStack(spacing: 40) {
            // Header (hrrngh timer is here now)
            HStack {
                VStack(alignment: .leading) {
                    Text("Score")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    
                    
                    
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(score)")
                            .font(.system(size: 48, weight: .bold))
                        
                        if multiplier > 1 {
                            Text("x\(multiplier)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.orange)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
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
                Button("Start", action: startGame)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(isGameActive)
                
                Button("Restart", action: resetGame)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .buttonStyle(.bordered)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
    
    private func tapButtonPressed() {
        guard isGameActive else { return }
        
        let now = Date()
        
        // Combo Logic
        if let lastTime = lastTapTime, now.timeIntervalSince(lastTime) <= 0.5 {
            multiplier += 1
        } else {
            multiplier = 1
        }
        
        lastTapTime = now
        
        // Add score with current multiplier
        withAnimation(.easeInOut(duration: 0.1)) {
            score += multiplier
        }
    }
    
    private func startGame() {
        resetGame()  // Clear previous state
        
        isGameActive = true
        score = 0
        timeLeft = 10
        multiplier = 1
        lastTapTime = nil
        
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
        // Keeping final multiplier visible at end for now (i'll change this later)
    }
    
    private func resetGame() {
        timer?.invalidate()
        timer = nil
        score = 0
        timeLeft = 10
        multiplier = 1
        lastTapTime = nil
        isGameActive = false
    }
}

#Preview {
    ContentView()
}
