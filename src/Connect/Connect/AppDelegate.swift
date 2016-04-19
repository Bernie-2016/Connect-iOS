import UIKit
import Swinject


class AppDelegate: UIResponder, UIApplicationDelegate {
    private var pushNotificationRegistrar: PushNotificationRegistrar!
    private var remoteNotificationHandler: RemoteNotificationHandler!
    private var newVersionNotifier: NewVersionNotifier!

    var container: Container!

    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        container = configureAppContainer(application)
        return true
    }

    func application(
        application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
            pushNotificationRegistrar = container.resolve(PushNotificationRegistrar.self)!
            remoteNotificationHandler = container.resolve(RemoteNotificationHandler.self)
            newVersionNotifier = container.resolve(NewVersionNotifier.self)

            let appBootstrapper = container.resolve(AppBootstrapper.self)!
            appBootstrapper.bootstrap()

            return true
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        pushNotificationRegistrar.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        pushNotificationRegistrar.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }


    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        remoteNotificationHandler.handleRemoteNotification(userInfo, fetchCompletionHandler: completionHandler)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        guard let controller = application.keyWindow?.rootViewController else {
            return
        }

        newVersionNotifier.presentAlertIfOutOfDateOnController(controller)
    }

    // MARK: Private

    private func configureAppContainer(application: UIApplication) -> Container {
        let container = ConnectContainerProvider.container(application)
        ActionsContainerConfigurator.configureContainer(container)
        EventsContainerConfigurator.configureContainer(container)
        GlobalUIContainerConfigurator.configureContainer(container)
        InfrastructureContainerConfigurator.configureContainer(container)
        MoreContainerConfigurator.configureContainer(container)
        NewsContainerConfigurator.configureContainer(container)
        OnboardingControllerConfigurator.configureContainer(container)
        UserNotificationContainerConfigurator.configureContainer(container)
        return container
    }
}
