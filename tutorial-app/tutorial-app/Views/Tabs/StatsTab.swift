//
//  StatsTab.swift
//  tutorial-app
//
//  Created by Student 2 on 2026-07-08.
//

import SwiftUI

struct StatsTab: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "chart.bar")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                Text("Stats")
                    .font(.largeTitle)
                Text("High scores and statistics")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Stats")
        }
    }
}
