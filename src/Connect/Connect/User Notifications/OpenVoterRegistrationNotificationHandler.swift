import Foundation


extension RemoteNotificationHandlerKeys.ActionTypes {
    static let OpenVoterRegistration = "openVoterRegistration"
}

class OpenVoterRegistrationNotificationHandler: RemoteNotificationHandler {
    let voterRegistrationController: UIViewController
    let tabBarController: UITabBarController

    init(voterRegistrationController: UIViewController,
         tabBarController: UITabBarController) {
        self.voterRegistrationController = voterRegistrationController
        self.tabBarController = tabBarController
    }

    func handleRemoteNotification(notificationUserInfo: NotificationUserInfo, fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

        guard let action = notificationUserInfo[RemoteNotificationHandlerKeys.ActionKey] as? String else {
            return
        }

        if action != RemoteNotificationHandlerKeys.ActionTypes.OpenVoterRegistration { return }

        tabBarController.selectedViewController = voterRegistrationController
        completionHandler(.NewData)
    }
}
