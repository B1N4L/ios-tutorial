//
//  NotificationService.swift
//  tutorial-app
//
//  Created by Binal Lokitha on 2026-07-17.
//

import Foundation
import UserNotifications

protocol NotificationServiceProtocol {
    func requestPermission()
    func scheduleDailyChallenge(at time: Date)
    func cancelDailyChallenge()
}

final class NotificationService: NotificationServiceProtocol {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()
    private let dailyIdentifier = "dailyChallenge"

    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    // Schedules a repeating notification at the hour/minute of the given date.
    func scheduleDailyChallenge(at time: Date) {
        cancelDailyChallenge()

        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge"
        content.body = "Time to beat your high score!"
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: dailyIdentifier,
                                            content: content,
                                            trigger: trigger)
        center.add(request)
    }

    func cancelDailyChallenge() {
        center.removePendingNotificationRequests(withIdentifiers: [dailyIdentifier])
    }
}
