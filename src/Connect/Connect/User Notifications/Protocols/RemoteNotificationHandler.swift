import UIKit

typealias NotificationUserInfo = [NSObject: AnyObject]

struct RemoteNotificationHandlerKeys {
    static let ActionKey = "action"
    static let IdentifierKey = "identifier"
    struct ActionTypes {}
}

protocol RemoteNotificationHandler {
    func handleRemoteNotification(notificationUserInfo: NotificationUserInfo)
}
