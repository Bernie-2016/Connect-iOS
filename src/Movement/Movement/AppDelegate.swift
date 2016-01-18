import UIKit
import Swinject

class AppDelegate: UIResponder, UIApplicationDelegate {
    private var pushNotificationRegistrar: PushNotificationRegistrar!
    private var userNotificationHandler: UserNotificationHandler!
    private var container: Container!

    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        container = configureAppContainer(application)
        pushNotificationRegistrar = container.resolve(PushNotificationRegistrar.self)!
        userNotificationHandler = container.resolve(UserNotificationHandler.self)
        return true
    }

    func application(
        application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
            let appBootstrapper = container.resolve(AppBootstrapper.self)!
            appBootstrapper.bootstrap()

            if let notificationUserInfo = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NotificationUserInfo {
                userNotificationHandler.handleRemoteNotification(notificationUserInfo)
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

    private func configureAppContainer(application: UIApplication) -> Container {
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
}
