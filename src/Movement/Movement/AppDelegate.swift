import UIKit
import AVFoundation
import Parse
import Fabric
import Swinject

class AppDelegate: UIResponder, UIApplicationDelegate {
    var pushNotificationRegistrar: PushNotificationRegistrar!
    var userNotificationHandler: UserNotificationHandler!
    var window: UIWindow?
    private var container: Container!


    func application(
        application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
            #if RELEASE
                Fabric.with([Crashlytics.self()])
            #endif

            container = configureAppContainer(application)

            pushNotificationRegistrar = container.resolve(PushNotificationRegistrar.self)!
            userNotificationHandler = container.resolve(UserNotificationHandler.self)


            if let notificationUserInfo = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NotificationUserInfo {
                userNotificationHandler.handleRemoteNotification(notificationUserInfo)
            }

            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            } catch {
                NSLog("Error setting audio category")
            }

            let onboardingWorkflow = container.resolve(OnboardingWorkflow.self)!
            onboardingWorkflow.initialViewController { (controller) -> Void in
                let theme = self.container.resolve(Theme.self)!

                self.window = UIWindow(frame: self.container.resolve(UIScreen.self, name: "main")!.bounds)
                self.window!.rootViewController = controller
                self.window!.backgroundColor = theme.defaultBackgroundColor()
                self.window!.makeKeyAndVisible()
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
        userNotificationHandler.handleRemoteNotification(userInfo)
    }

    // MARK: Private

    func configureAppContainer(application: UIApplication) -> Container {
        let container = MovementContainerProvider.container(application)
        ActionsContainerConfigurator.configureContainer(container)
        EventsContainerConfigurator.configureContainer(container)
        GlobalUIContainerConfigurator.configureContainer(container)
        InfrastructureContainerConfigurator.configureContainer(container)
        IssuesContainerConfigurator.configureContainer(container)
        MoreContainerConfigurator.configureContainer(container)
        NewsContainerConfigurator.configureContainer(container)
        OnboardingControllerConfigurator.configureContainer(container)
        UserNotificationContainerConfigurator.configureContainer(container)
        return container
    }

    private func configureTabBar() {
        let theme = container.resolve(Theme.self)!
        UITabBar.appearance().tintColor = theme.tabBarActiveTextColor()
        UITabBar.appearance().translucent = false
        UINavigationBar.appearance().tintColor = theme.navigationBarTextColor()
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: theme.navigationBarButtonFont(), NSForegroundColorAttributeName: theme.navigationBarTextColor()], forState: UIControlState.Normal)
    }
}
