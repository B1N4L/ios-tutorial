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
            MapKitView()
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("Map")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
