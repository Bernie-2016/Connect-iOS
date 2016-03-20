import Foundation


extension UserNotificationHandlerKeys.ActionTypes {
    static let OpenActionAlert = "openActionAlert"
}

class OpenActionAlertNotificationHandler: UserNotificationHandler {
    let actionAlertNavigationController: UINavigationController
    let tabBarController: UITabBarController

    init(actionsNavigationController: UINavigationController,
        tabBarController: UITabBarController) {
            self.actionAlertNavigationController = actionsNavigationController
            self.tabBarController = tabBarController
    }

    func handleRemoteNotification(notificationUserInfo: NotificationUserInfo) {
        guard let action = notificationUserInfo[UserNotificationHandlerKeys.ActionKey] as? String else {
            return
        }

        if action != UserNotificationHandlerKeys.ActionTypes.OpenActionAlert { return }

        tabBarController.selectedViewController = actionAlertNavigationController
    }
}
