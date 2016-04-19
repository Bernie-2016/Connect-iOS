import Foundation

class PushNotificationHandlerDispatcher: RemoteNotificationHandler {
    let handlers: [RemoteNotificationHandler]

    init(handlers: [RemoteNotificationHandler]) {
        self.handlers = handlers
    }

    func handleRemoteNotification(notificationUserInfo: NotificationUserInfo) {
        for handler in handlers {
            handler.handleRemoteNotification(notificationUserInfo)
        }
    }
}
