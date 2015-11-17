import UIKit


class AppDelegate: UIResponder, UIApplicationDelegate {
    var pushNotificationRegistrar: PushNotificationRegistrar!

    func application(
        application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
            let appBootstrapper = AppBootstrapper()

            self.pushNotificationRegistrar = appBootstrapper.pushNotificationRegistrar
            self.pushNotificationRegistrar.registerForRemoteNotificationsWithApplication(application)

            return appBootstrapper.bootstrap()
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        self.pushNotificationRegistrar.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        self.pushNotificationRegistrar.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
}
