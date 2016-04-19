import UIKit

protocol PushNotificationRegistrar {
    func registerForRemoteNotificationsWithApplication(application: RemoteNotificationRegisterable)
    func application(application: RemoteNotificationRegisterable, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)
    func application(application: RemoteNotificationRegisterable, didFailToRegisterForRemoteNotificationsWithError error: NSError)
}
