import UIKit
import Parse

class ConcretePushNotificationRegistrar: PushNotificationRegistrar {
    let installation: PFInstallation

    init(installation: PFInstallation) {
        self.installation = installation
    }

    func registerForRemoteNotificationsWithApplication(application: ApplicationUserNotificationHandler) {
        let types = UIUserNotificationType([.Alert, .Badge, .Sound])
        let settings = UIUserNotificationSettings(forTypes: types, categories: nil)

        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }

    func application(application: ApplicationUserNotificationHandler, didFailToRegisterForRemoteNotificationsWithError error: NSError) {

    }

    func application(application: ApplicationUserNotificationHandler, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        self.installation.setDeviceTokenFromData(deviceToken)
        self.installation.saveInBackground()
    }
}
