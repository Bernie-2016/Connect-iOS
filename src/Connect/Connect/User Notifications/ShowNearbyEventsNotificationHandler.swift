import Foundation


extension RemoteNotificationHandlerKeys.ActionTypes {
    static let ShowNearbyEvents = "showNearbyEvents"
}

class ShowNearbyEventsNotificationHandler: RemoteNotificationHandler {
    let eventsNavigationController: UINavigationController
    let tabBarController: UITabBarController
    let nearbyEventsUseCase: NearbyEventsUseCase
    let radiusDataSource: RadiusDataSource
    let workerQueue: NSOperationQueue

    init(eventsNavigationController: UINavigationController, tabBarController: UITabBarController, nearbyEventsUseCase: NearbyEventsUseCase, radiusDataSource: RadiusDataSource, workerQueue: NSOperationQueue) {
        self.eventsNavigationController = eventsNavigationController
        self.tabBarController = tabBarController
        self.nearbyEventsUseCase = nearbyEventsUseCase
        self.radiusDataSource = radiusDataSource
        self.workerQueue = workerQueue
    }

    func handleRemoteNotification(notificationUserInfo: NotificationUserInfo) {
        guard let action = notificationUserInfo[RemoteNotificationHandlerKeys.ActionKey] as? String else {
            return
        }

        if action != RemoteNotificationHandlerKeys.ActionTypes.ShowNearbyEvents { return }

        tabBarController.selectedViewController = eventsNavigationController
        eventsNavigationController.popToRootViewControllerAnimated(false)

        radiusDataSource.resetToDefaultSearchRadius()

        workerQueue.addOperationWithBlock {
            self.nearbyEventsUseCase.fetchNearbyEventsWithinRadiusMiles(self.radiusDataSource.currentMilesValue)
        }
    }
}
