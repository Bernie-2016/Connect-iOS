import UIKit

typealias NotificationUserInfo = [NSObject: AnyObject]

struct UserNotificationHandlerKeys {
    static let ActionKey = "action"
    static let IdentifierKey = "identifier"
    struct ActionTypes {}
}

protocol UserNotificationHandler {
    func handleRemoteNotification(notificationUserInfo: NotificationUserInfo)
}
