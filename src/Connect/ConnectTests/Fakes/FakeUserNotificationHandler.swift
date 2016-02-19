@testable import Connect

class FakeUserNotificationHandler: UserNotificationHandler {
    var lastReceivedUserInfo: NotificationUserInfo!

    func handleRemoteNotification(notificationUserInfo: NotificationUserInfo) {
        lastReceivedUserInfo = notificationUserInfo
    }
}
