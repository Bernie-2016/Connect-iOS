import UIKit

protocol ApplicationUserNotificationHandler {
    func registerForRemoteNotifications()
    func registerUserNotificationSettings(notificationSettings: UIUserNotificationSettings)
}

extension UIApplication: ApplicationUserNotificationHandler {}
