//
//  SettingsTab.swift
//  tutorial-app
//
//  Created by Student 2 on 2026-07-08.
//

import SwiftUI

struct SettingsTab: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "gear")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                Text("Settings")
                    .font(.largeTitle)
                Text("App settings and preferences")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Settings")
        }
    }
}
