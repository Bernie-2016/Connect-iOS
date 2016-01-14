import Foundation

class PushNotificationHandlerDispatcher: UserNotificationHandler {
    let handlers: [UserNotificationHandler]

    init(handlers: [UserNotificationHandler]) {
        self.handlers = handlers
    }

    func handleRemoteNotification(notificationUserInfo: NotificationUserInfo) {
        for handler in handlers {
            handler.handleRemoteNotification(notificationUserInfo)
        }
    }
}
