//
//  buttonPositioning.swift
//  tutorial-app
//
//  Created by Student 2 on 2026-06-11.
//

import Foundation

import SwiftUI

struct ButtonPositioning: View {
    @State private var circlePosition: CGPoint = .zero
    @State private var screenSize: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Blue Header
            Text("\(screenSize)")
                .font(.callout)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
            
            // Blue Header
            Text("\(circlePosition)")
                .font(.callout)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
            
            // Middle Area - Circle moves only here
            GeometryReader { geometry in
                ZStack {
                    Color(.black)
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 60, height: 60)
                        .position(circlePosition)
                        .shadow(radius: 10)
                }
                .onAppear {
                    screenSize = geometry.size
                    placeCircleRandomly()
                }
                // Fixed: Modern onChange syntax (iOS 17+)
                .onChange(of: geometry.size) { _, newSize in
                    screenSize = newSize
                }
            }
            
            // Blue Footer
            Button(action: {
                placeCircleRandomly()
            }) {
                Text("Place Circle Randomly")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.9))
            }
            .padding(.vertical, 16)
            .background(Color.blue)
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    // MARK: - Helper Function
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
}

#Preview {
    ContentView()
}
