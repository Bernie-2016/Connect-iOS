@testable import Connect

class FakeRemoteNotificationHandler: RemoteNotificationHandler {
    var lastReceivedUserInfo: NotificationUserInfo!

    func handleRemoteNotification(notificationUserInfo: NotificationUserInfo) {
        lastReceivedUserInfo = notificationUserInfo
    }
}
