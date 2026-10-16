import Foundation
import UserNotifications

/// iOS hides notifications while the app is open unless a delegate says otherwise.
/// This is why the test notification "did nothing" — it was delivered, just not shown.
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }
}

/// Real iOS notifications (Notification Center), not in-app banners.
enum Notifier {
    static func configure() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    static func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    /// delay 0 posts it straight away.
    static func send(title: String, body: String, delay: TimeInterval = 0) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger: UNNotificationTrigger? = delay > 0
            ? UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
            : nil

        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    static func clearAll() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
