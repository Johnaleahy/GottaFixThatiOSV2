//
//  NotificationScheduler.swift
//  GottaFixThat
//
//  Created on 2026-06-03.
//

import Foundation
import UserNotifications

enum NotificationSchedulerError: LocalizedError {
    case authorizationDenied
    case invalidReminderDate

    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Notifications are disabled for GottaFixThat. Enable them in Settings to receive reminders."
        case .invalidReminderDate:
            return "The reminder date is invalid."
        }
    }
}

@MainActor
final class NotificationScheduler {
    static let shared = NotificationScheduler()

    private let center = UNUserNotificationCenter.current()

    private init() {}

    func syncReminder(for item: FixItem) async throws {
        let identifier = notificationIdentifier(for: item)

        guard item.notificationsEnabled,
              !item.isCompleted,
              let reminderDate = item.reminderDate else {
            center.removePendingNotificationRequests(withIdentifiers: [identifier])
            return
        }

        guard reminderDate > Date() else {
            center.removePendingNotificationRequests(withIdentifiers: [identifier])
            throw NotificationSchedulerError.invalidReminderDate
        }

        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            break
        case .notDetermined:
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            guard granted else {
                throw NotificationSchedulerError.authorizationDenied
            }
        case .denied:
            throw NotificationSchedulerError.authorizationDenied
        @unknown default:
            throw NotificationSchedulerError.authorizationDenied
        }

        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = item.title
        content.body = reminderBody(for: item)
        content.sound = .default
        content.userInfo = [
            "itemID": item.id.uuidString
        ]

        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        try await center.add(request)
    }

    func cancelReminder(for item: FixItem) {
        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier(for: item)])
    }

    private func notificationIdentifier(for item: FixItem) -> String {
        "fixitem-\(item.id.uuidString)"
    }

    private func reminderBody(for item: FixItem) -> String {
        if let listName = item.list?.name, let propertyName = item.list?.property?.name {
            return "Reminder for \(listName) at \(propertyName)."
        }
        if let listName = item.list?.name {
            return "Reminder for \(listName)."
        }
        return "You asked to be reminded about this task."
    }
}
