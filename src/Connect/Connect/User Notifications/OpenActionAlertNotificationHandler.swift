import Foundation


extension RemoteNotificationHandlerKeys.ActionTypes {
    static let OpenActionAlert = "openActionAlert"
}

class OpenActionAlertNotificationHandler: RemoteNotificationHandler {
    let actionAlertNavigationController: UINavigationController
    let tabBarController: UITabBarController

    init(actionsNavigationController: UINavigationController,
        tabBarController: UITabBarController) {
            self.actionAlertNavigationController = actionsNavigationController
            self.tabBarController = tabBarController
    }

    func handleRemoteNotification(notificationUserInfo: NotificationUserInfo) {
        guard let action = notificationUserInfo[RemoteNotificationHandlerKeys.ActionKey] as? String else {
            return
        }

        if action != RemoteNotificationHandlerKeys.ActionTypes.OpenActionAlert { return }

        tabBarController.selectedViewController = actionAlertNavigationController
    }
}
