import UIKit

protocol UserNotificationRegisterable {
    func registerForRemoteNotifications()
    func registerUserNotificationSettings(notificationSettings: UIUserNotificationSettings)
}

extension UIApplication: UserNotificationRegisterable {}
