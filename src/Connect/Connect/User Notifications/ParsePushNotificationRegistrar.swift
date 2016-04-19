import UIKit
import Parse

class ParsePushNotificationRegistrar: PushNotificationRegistrar {
    let installation: PFInstallation

    init(installation: PFInstallation) {
        self.installation = installation
    }

    func registerForRemoteNotificationsWithApplication(application: RemoteNotificationRegisterable) {
        let types = UIUserNotificationType([.Alert, .Badge, .Sound])
        let settings = UIUserNotificationSettings(forTypes: types, categories: nil)

        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }

    func application(application: RemoteNotificationRegisterable, didFailToRegisterForRemoteNotificationsWithError error: NSError) {

    }

    func application(application: RemoteNotificationRegisterable, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        self.installation.setDeviceTokenFromData(deviceToken)
        self.installation.saveInBackground()
    }
}
