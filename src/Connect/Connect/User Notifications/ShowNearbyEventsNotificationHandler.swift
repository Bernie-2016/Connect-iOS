import Foundation


extension UserNotificationHandlerKeys.ActionTypes {
    static let ShowNearbyEvents = "showNearbyEvents"
}

class ShowNearbyEventsNotificationHandler: UserNotificationHandler {
    let eventsNavigationController: UINavigationController
    let tabBarController: UITabBarController
    let nearbyEventsUseCase: NearbyEventsUseCase
    let radiusDataSource: RadiusDataSource

    init(eventsNavigationController: UINavigationController, tabBarController: UITabBarController, nearbyEventsUseCase: NearbyEventsUseCase, radiusDataSource: RadiusDataSource) {
        self.eventsNavigationController = eventsNavigationController
        self.tabBarController = tabBarController
        self.nearbyEventsUseCase = nearbyEventsUseCase
        self.radiusDataSource = radiusDataSource
    }

    func handleRemoteNotification(notificationUserInfo: NotificationUserInfo) {
        guard let action = notificationUserInfo[UserNotificationHandlerKeys.ActionKey] as? String else {
            return
        }

        if action != UserNotificationHandlerKeys.ActionTypes.ShowNearbyEvents { return }

        tabBarController.selectedViewController = eventsNavigationController
        eventsNavigationController.popToRootViewControllerAnimated(false)

        radiusDataSource.resetToDefaultSearchRadius()
        nearbyEventsUseCase.fetchNearbyEventsWithinRadiusMiles(radiusDataSource.currentMilesValue)
    }
}
