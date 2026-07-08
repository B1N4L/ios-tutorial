//
//  MapTab.swift
//  tutorial-app
//
//  Created by Student 2 on 2026-07-08.
//

import SwiftUI

struct MapTab: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "map")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                Text("Map")
                    .font(.largeTitle)
                Text("Your game locations will show here")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Map")
        }
    }
}
