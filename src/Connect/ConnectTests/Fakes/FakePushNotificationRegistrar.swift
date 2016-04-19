@testable import Connect

class FakePushNotificationRegistrar: PushNotificationRegistrar {
    var lastAppUsedForRegistration: RemoteNotificationRegisterable!

    func registerForRemoteNotificationsWithApplication(application: RemoteNotificationRegisterable) {
        self.lastAppUsedForRegistration = application
    }

    var lastFailedRegistrationApplication: RemoteNotificationRegisterable!
    var lastFailedRegistrationError: NSError!
    func application(application: RemoteNotificationRegisterable, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        lastFailedRegistrationApplication = application
        lastFailedRegistrationError = error
    }

    var lastSuccessfullyRegisteredApplication: RemoteNotificationRegisterable!
    var lastSuccessfullyRegisteredDeviceToken: NSData!
    func application(application: RemoteNotificationRegisterable, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        lastSuccessfullyRegisteredApplication = application
        lastSuccessfullyRegisteredDeviceToken = deviceToken
    }
}
