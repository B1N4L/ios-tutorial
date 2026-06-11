import SwiftUI
import Combine

// TODO: REFACTOR TO PURE FUNCTIONS TO CREATE UTILS IN NEXT INCREMENT

struct Game: View {
    @State private var score = 0
    @State private var timeLeft = 10
    @State private var isGameActive = false
    
    // Combo System
    @State private var multiplier = 1
    @State private var comboStartedAt: Date? = nil
    
    // Random Button Positioning
    @State private var circlePosition: CGPoint = .zero
    @State private var screenSize: CGSize = .zero
    
    // Timer Publisher (modern method)
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Button Size change
    @State private var buttonSize: CGFloat = 280
    //derived variable: didn't using a separate state to increase performance & memory
    private var buttonFontSize: CGFloat {
        buttonSize * 0.21
    }
    
    var body: some View {
        VStack(spacing: 40) {
            // Header: Score + Multiplier + Timer(temporary)
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
            
            // Main Section
            GeometryReader { geometry in HStack {
                    
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
                                // .frame(width: 280, height: 280)
                                .frame(width: buttonSize, height: buttonSize) //decreasing button size
                                .shadow(radius: 15)
                            
                            Text("TAP!")
                                .font(.system(size: buttonFontSize, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!isGameActive)
                    .scaleEffect(isGameActive ? 1.0 : 0.95)
                    .animation(.spring(response: 0.3), value: isGameActive)
                    .position(circlePosition)
                    .onAppear {
                            screenSize = geometry.size
                        
                        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                            if isGameActive {
                                placeCircleRandomly()
                            }
                        }

                        }
                        // Fixed: Modern onChange syntax (iOS 17+)
                        .onChange(of: geometry.size) { _, newSize in
                            screenSize = newSize
                        }
                    
                }}

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
        
        // Timer using Timer.publish + onReceive
        .onReceive(timer) { _ in
            guard isGameActive && timeLeft > 0 else { return }
            
            timeLeft -= 1
            decreaseButtonSize()
            if timeLeft == 0 {
                endGame()
            }
        }
    }
    
    private func tapButtonPressed() {
        guard isGameActive else { return }

        comboChange()
        
        // Add score with current multiplier
        withAnimation(.easeInOut(duration: 0.1)) {
            score += multiplier
        }
    }
    
    // Combo Logic
    private func comboChange(){
        let now = Date()
        // Combo Logic
        if let lastTime = comboStartedAt, now.timeIntervalSince(lastTime) <= 0.5 {
            multiplier += 1
        } else {
            multiplier = 1
        }
        comboStartedAt = now
    }
    
    private func startGame() {
        resetGame()
        
        isGameActive = true
        score = 0
        timeLeft = 10
        multiplier = 1
        comboStartedAt = nil
    }
    
    private func endGame() {
        isGameActive = false
        // Final multiplier stays visible
    }
    
    private func resetGame() {
        score = 0
        timeLeft = 10
        multiplier = 1
        comboStartedAt = nil
        isGameActive = false
    }
    
    private func placeCircleRandomly() {
        guard screenSize.width > 0 && screenSize.height > 0 else { return }
        
        let radius: CGFloat = 30
        let randomX = CGFloat.random(in: radius...(screenSize.width - radius))
        let randomY = CGFloat.random(in: radius...(screenSize.height - radius))
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            circlePosition = CGPoint(x: randomX, y: randomY)
        }
        
        print("middleSize: \(screenSize)")
        print("circlePosition: \(circlePosition)")
    }
    
    private func decreaseButtonSize() {
        let maxSize: CGFloat = 280
        let minSize: CGFloat = 80
        let progress = CGFloat(timeLeft) / 10.0
        buttonSize = minSize + (maxSize - minSize) * progress
    }
    
}

#Preview {
    ContentView()
}
