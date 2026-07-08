//
//  HomeTab.swift
//  tutorial-app
//
//  Created by Student 2 on 2026-07-08.
//

import SwiftUI

struct HomeTab: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "gamecontroller")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                Text("Home")
                    .font(.largeTitle)
                Text("Games will appear here")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Games")
        }
    }
}
