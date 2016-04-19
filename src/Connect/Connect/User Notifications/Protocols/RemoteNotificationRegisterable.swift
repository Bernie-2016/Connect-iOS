import UIKit

protocol RemoteNotificationRegisterable {
    func registerForRemoteNotifications()
    func registerUserNotificationSettings(notificationSettings: UIUserNotificationSettings)
}

extension UIApplication: RemoteNotificationRegisterable {}
