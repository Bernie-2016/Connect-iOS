import Foundation

extension UserNotificationHandlerKeys.ActionTypes {
    static let OpenVideo = "openVideo"
}


class OpenVideoNotificationHandler: UserNotificationHandler {
    let newsNavigationController: UINavigationController
    let interstitialController: UIViewController
    let tabBarController: UITabBarController
    let newsFeedItemControllerProvider: NewsFeedItemControllerProvider
    let videoService: VideoService

    init(
        newsNavigationController: UINavigationController,
        interstitialController: UIViewController,
        tabBarController: UITabBarController,
        newsFeedItemControllerProvider: NewsFeedItemControllerProvider,
        videoService: VideoService) {
            self.newsNavigationController = newsNavigationController
            self.interstitialController = interstitialController
            self.tabBarController = tabBarController
            self.newsFeedItemControllerProvider = newsFeedItemControllerProvider
            self.videoService = videoService
    }

    func handleRemoteNotification(notificationUserInfo: NotificationUserInfo) {
        guard let action = notificationUserInfo[UserNotificationHandlerKeys.ActionKey] as? String else {
            return
        }

        if action != UserNotificationHandlerKeys.ActionTypes.OpenVideo { return }

        guard let identifier = notificationUserInfo[UserNotificationHandlerKeys.IdentifierKey] as? String else {
            return
        }

        tabBarController.selectedViewController = newsNavigationController
        newsNavigationController.pushViewController(interstitialController, animated: false)

        let videoFuture = videoService.fetchVideo(identifier)

        videoFuture.then { video in
            let controller = self.newsFeedItemControllerProvider.provideInstanceWithNewsFeedItem(video)
            self.newsNavigationController.popViewControllerAnimated(false)
            self.newsNavigationController.pushViewController(controller, animated: false)
            }.error { error in
                self.newsNavigationController.popViewControllerAnimated(false)
        }
    }
}
