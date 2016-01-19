@testable import Movement

class FakeUserNotificationHandler: UserNotificationHandler {
    var lastReceivedUserInfo: NotificationUserInfo!

    func handleRemoteNotification(notificationUserInfo: NotificationUserInfo) {
        lastReceivedUserInfo = notificationUserInfo
    }
}
