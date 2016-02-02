import Foundation


extension UserNotificationHandlerKeys.ActionTypes {
    static let OpenActionAlert = "openActionAlert"
}

class OpenActionAlertNotificationHandler: UserNotificationHandler {
    let actionAlertNavigationController: UINavigationController
    let interstitialController: UIViewController
    let tabBarController: UITabBarController
    let actionAlertControllerProvider: ActionAlertControllerProvider
    let actionAlertService: ActionAlertService

    init(actionsNavigationController: UINavigationController,
        interstitialController: UIViewController,
        tabBarController: UITabBarController,
        actionAlertControllerProvider: ActionAlertControllerProvider,
        actionAlertService: ActionAlertService) {
            self.actionAlertNavigationController = actionsNavigationController
            self.interstitialController = interstitialController
            self.tabBarController = tabBarController
            self.actionAlertControllerProvider = actionAlertControllerProvider
            self.actionAlertService = actionAlertService
    }

    func handleRemoteNotification(notificationUserInfo: NotificationUserInfo) {
        guard let action = notificationUserInfo[UserNotificationHandlerKeys.ActionKey] as? String else {
            return
        }

        if action != UserNotificationHandlerKeys.ActionTypes.OpenActionAlert { return }

        guard let identifier = notificationUserInfo[UserNotificationHandlerKeys.IdentifierKey] as? String else {
            return
        }

        tabBarController.selectedViewController = actionAlertNavigationController
        actionAlertNavigationController.pushViewController(interstitialController, animated: false)

        let actionAlertFuture = actionAlertService.fetchActionAlert(identifier)

        actionAlertFuture.then { actionAlert in
            let controller = self.actionAlertControllerProvider.provideInstanceWithActionAlert(actionAlert)
            self.actionAlertNavigationController.popViewControllerAnimated(false)
            self.actionAlertNavigationController.pushViewController(controller, animated: false)
            }.error { error in
                self.actionAlertNavigationController.popViewControllerAnimated(false)
        }
    }
}
