@testable import Connect

class FakeRemoteNotificationHandler: RemoteNotificationHandler {
    var lastReceivedUserInfo: NotificationUserInfo!
    var lastReceivedCompletionHandler: ((UIBackgroundFetchResult) -> ())!

    func handleRemoteNotification(notificationUserInfo: NotificationUserInfo, fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        lastReceivedUserInfo = notificationUserInfo
        lastReceivedCompletionHandler = completionHandler
    }
}
