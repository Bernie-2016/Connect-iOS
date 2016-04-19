import Foundation

class PushNotificationHandlerDispatcher: RemoteNotificationHandler {
    let handlers: [RemoteNotificationHandler]

    init(handlers: [RemoteNotificationHandler]) {
        self.handlers = handlers
    }

    func handleRemoteNotification(notificationUserInfo: NotificationUserInfo, fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        for handler in handlers {
            handler.handleRemoteNotification(notificationUserInfo, fetchCompletionHandler: completionHandler)
        }
    }
}
