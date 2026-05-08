import Foundation
import UserNotifications

enum ReminderService {
    static let monthlyIdentifier = "nestegg.monthly.update"

    static func currentAuthorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    /// Requests permission. Returns `true` if the user has granted (or previously granted) authorization.
    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let status = await center.notificationSettings().authorizationStatus
        if status == .authorized || status == .provisional || status == .ephemeral {
            return true
        }
        if status == .denied {
            return false
        }
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// Schedules (or cancels) a monthly local notification on the 1st at 9am local time.
    static func setMonthlyReminder(enabled: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [monthlyIdentifier])

        guard enabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Time to update NestEgg"
        content.body = "Log this month's values to keep your net worth fresh."
        content.sound = .default

        var components = DateComponents()
        components.day = 1
        components.hour = 9

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: monthlyIdentifier,
            content: content,
            trigger: trigger
        )

        center.add(request) { _ in }
    }
}
