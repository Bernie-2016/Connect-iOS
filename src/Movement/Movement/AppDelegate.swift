import UIKit


class AppDelegate: UIResponder, UIApplicationDelegate {
    var pushNotificationRegistrar: PushNotificationRegistrar!
    let appBootstrapper = AppBootstrapper()

    func application(
        application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
            self.appBootstrapper.bootstrapWithApplication(application)
            self.pushNotificationRegistrar = appBootstrapper.pushNotificationRegistrar

            return true
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        self.pushNotificationRegistrar.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        self.pushNotificationRegistrar.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
}
