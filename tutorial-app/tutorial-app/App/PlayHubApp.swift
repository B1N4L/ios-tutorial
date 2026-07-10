//
//  PlayHubApp.swift
//  tutorial-app
//
//  Created by Student 2 on 2026-07-08.
//

import SwiftUI

@main
struct PlayHubApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            HomeTab()
                .tabItem {
                    Label("Home", systemImage: "gamecontroller")
                }

            StatsTab()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }

            MapTab()
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {
            LocationService.shared.requestPermission()
        }
    }
}
