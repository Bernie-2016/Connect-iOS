import UIKit

protocol PushNotificationRegistrar {
    func registerForRemoteNotificationsWithApplication(application: UserNotificationRegisterable)
    func application(application: UserNotificationRegisterable, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)
    func application(application: UserNotificationRegisterable, didFailToRegisterForRemoteNotificationsWithError error: NSError)
}
