//
//  SettingsTab.swift
//  tutorial-app
//
//  Created by Student 2 on 2026-07-08.
//

import SwiftUI

struct SettingsTab: View {
    // 64800 = 18:00 on the reference date; only hour/minute are used.
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("dailyChallengeTime") private var dailyChallengeTime: Double = 64800

    @State private var showResetConfirmation = false

    private let notificationService: NotificationServiceProtocol = NotificationService.shared

    private var reminderTime: Binding<Date> {
        Binding(
            get: { Date(timeIntervalSinceReferenceDate: dailyChallengeTime) },
            set: { dailyChallengeTime = $0.timeIntervalSinceReferenceDate }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Challenge") {
                    Toggle("Enable notifications", isOn: $notificationsEnabled)

                    if notificationsEnabled {
                        DatePicker("Reminder time",
                                   selection: reminderTime,
                                   displayedComponents: .hourAndMinute)
                    }
                }

                Section {
                    Button("Reset All Stats", role: .destructive) {
                        showResetConfirmation = true
                    }
                }
            }
            .navigationTitle("Settings")
            .onChange(of: notificationsEnabled) { _, enabled in
                applyNotificationSettings(enabled: enabled)
            }
            .onChange(of: dailyChallengeTime) { _, _ in
                applyNotificationSettings(enabled: notificationsEnabled)
            }
            .confirmationDialog("Reset all stats?",
                                isPresented: $showResetConfirmation,
                                titleVisibility: .visible) {
                Button("Reset", role: .destructive) {
                    HighScoreService.shared.clearAll()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This permanently deletes every saved game session.")
            }
        }
    }

    private func applyNotificationSettings(enabled: Bool) {
        if enabled {
            notificationService.requestPermission()
            notificationService.scheduleDailyChallenge(at: reminderTime.wrappedValue)
        } else {
            notificationService.cancelDailyChallenge()
        }
    }
}
