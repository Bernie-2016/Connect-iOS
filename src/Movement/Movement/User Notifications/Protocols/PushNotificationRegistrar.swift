import UIKit

protocol PushNotificationRegistrar {
    func registerForRemoteNotificationsWithApplication(application: ApplicationUserNotificationHandler)
    func application(application: ApplicationUserNotificationHandler, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)
    func application(application: ApplicationUserNotificationHandler, didFailToRegisterForRemoteNotificationsWithError error: NSError)
}
