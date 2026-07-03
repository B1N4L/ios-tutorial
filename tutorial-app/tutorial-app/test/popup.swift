//
//  popup.swift
//  tutorial-app
//
//  Created by Student 2 on 2026-06-27.
//

import Foundation

import SwiftUI

struct PopUp: View {
    @State private var isPopupOpen: Bool  = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Blue Header
            Text("test")
                .font(.callout)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
            

            // Blue Footer
            Button(action: {
                handlePopup()
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
    
    // MARK: - Popup Function
    private func handlePopup() {
        isPopupOpen = !isPopupOpen
    }
}

#Preview {
    ContentView()
}
