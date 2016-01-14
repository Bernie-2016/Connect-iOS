import UIKit
import AVFoundation

class AppDelegate: UIResponder, UIApplicationDelegate {
    var pushNotificationRegistrar: PushNotificationRegistrar!
    var pushNotificationHandlerDispatcher: PushNotificationHandlerDispatcher!
    let appBootstrapper = AppBootstrapper()

    func application(
        application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
            appBootstrapper.bootstrapWithApplication(application)
            pushNotificationRegistrar = appBootstrapper.pushNotificationRegistrar
            pushNotificationHandlerDispatcher = appBootstrapper.pushNotificationHandlerDispatcher

            if let notificationUserInfo = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NotificationUserInfo {
                pushNotificationHandlerDispatcher.handleRemoteNotification(notificationUserInfo)
            }

            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            } catch {
                NSLog("Error setting audio category")
            }

            return true
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        pushNotificationRegistrar.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        pushNotificationRegistrar.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        pushNotificationHandlerDispatcher.handleRemoteNotification(userInfo)
    }
}
