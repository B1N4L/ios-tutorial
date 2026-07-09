//
//  MapTab.swift
//  tutorial-app
//
//  Created by Student 2 on 2026-07-08.
//

import SwiftUI
import MapKit

struct MapTab: View {
    @State private var sessions: [GameSession] = []
    @State private var selected: GameSession?

    private var locatedSessions: [GameSession] {
        sessions.filter { $0.latitude != 0 || $0.longitude != 0 }
    }

    var body: some View {
        NavigationStack {
            Group {
                if locatedSessions.isEmpty {
                    emptyState
                } else {
                    Map {
                        ForEach(locatedSessions) { session in
                            Annotation(session.mode.rawValue.capitalized,
                                       coordinate: coordinate(for: session)) {
                                Button {
                                    selected = session
                                } label: {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title)
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            sessions = HighScoreService.shared.loadAll()
        }
        .alert(selected?.mode.rawValue.capitalized ?? "",
               isPresented: Binding(
                get: { selected != nil },
                set: { if !$0 { selected = nil } }
               ),
               presenting: selected) { _ in
            Button("OK", role: .cancel) { }
        } message: { session in
            Text("Score: \(session.score, format: .number.precision(.fractionLength(0)))")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "map")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            Text("No game locations yet")
                .font(.title2)
                .foregroundColor(.secondary)
            Text("Play a game with location enabled to drop a pin here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private func coordinate(for session: GameSession) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: session.latitude, longitude: session.longitude)
    }
}
