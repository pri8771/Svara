import Foundation
import UserNotifications

/// Schedules gentle daily reminders for morning and evening practice.
protocol NotificationService {
    func authorizationStatus() async -> UNAuthorizationStatus
    @discardableResult func requestAuthorization() async -> Bool
    /// Schedules (or reschedules) the daily reminders at the given hours.
    func scheduleDailyReminders(morningHour: Int, eveningHour: Int) async
    func cancelAllReminders()
}

final class LocalNotificationService: NotificationService {
    private let center: UNUserNotificationCenter

    private enum ID {
        static let morning = "svara.reminder.morning"
        static let evening = "svara.reminder.evening"
    }

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    @discardableResult
    func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    func scheduleDailyReminders(morningHour: Int, eveningHour: Int) async {
        cancelAllReminders()

        let morning = makeRequest(
            id: ID.morning,
            hour: morningHour,
            title: "Good morning 🌅",
            body: "Begin your day with a 3-minute mantra. Your streak is waiting."
        )
        let evening = makeRequest(
            id: ID.evening,
            hour: eveningHour,
            title: "Evening wind-down 🌙",
            body: "Take a calm moment for your evening prayer and reflection."
        )

        try? await center.add(morning)
        try? await center.add(evening)
    }

    func cancelAllReminders() {
        center.removePendingNotificationRequests(withIdentifiers: [ID.morning, ID.evening])
    }

    private func makeRequest(id: String, hour: Int, title: String, body: String) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        return UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    }
}
