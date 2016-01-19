@testable import Movement

class FakePushNotificationRegistrar: PushNotificationRegistrar {
    var lastAppUsedForRegistration: UserNotificationRegisterable!

    func registerForRemoteNotificationsWithApplication(application: UserNotificationRegisterable) {
        self.lastAppUsedForRegistration = application
    }

    var lastFailedRegistrationApplication: UserNotificationRegisterable!
    var lastFailedRegistrationError: NSError!
    func application(application: UserNotificationRegisterable, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        lastFailedRegistrationApplication = application
        lastFailedRegistrationError = error
    }

    var lastSuccessfullyRegisteredApplication: UserNotificationRegisterable!
    var lastSuccessfullyRegisteredDeviceToken: NSData!
    func application(application: UserNotificationRegisterable, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        lastSuccessfullyRegisteredApplication = application
        lastSuccessfullyRegisteredDeviceToken = deviceToken
    }
}
