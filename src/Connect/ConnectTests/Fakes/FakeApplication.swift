import Foundation
@testable import Connect

class FakeApplication: UserNotificationRegisterable {
    var callCount = 0

    var lastRegisteredUserNotificationSettings: UIUserNotificationSettings!
    var registerUserNotificationSettingsCallIndex: Int!

    func registerUserNotificationSettings(notificationSettings: UIUserNotificationSettings) {
        self.lastRegisteredUserNotificationSettings = notificationSettings
        self.callCount++
        self.registerUserNotificationSettingsCallIndex = self.callCount
    }

    var registerForRemoteNotificationsCallIndex: Int!
    func registerForRemoteNotifications() {
        self.callCount++
        self.registerForRemoteNotificationsCallIndex = self.callCount
    }

}
