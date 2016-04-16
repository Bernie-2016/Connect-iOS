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
    let resultQueue: NSOperationQueue

    init(
        newsNavigationController: UINavigationController,
        interstitialController: UIViewController,
        tabBarController: UITabBarController,
        newsFeedItemControllerProvider: NewsFeedItemControllerProvider,
        videoService: VideoService,
        resultQueue: NSOperationQueue) {
        self.newsNavigationController = newsNavigationController
        self.interstitialController = interstitialController
        self.tabBarController = tabBarController
        self.newsFeedItemControllerProvider = newsFeedItemControllerProvider
        self.videoService = videoService
        self.resultQueue = resultQueue
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
            self.resultQueue.addOperationWithBlock {
                let controller = self.newsFeedItemControllerProvider.provideInstanceWithNewsFeedItem(video)
                self.newsNavigationController.popViewControllerAnimated(false)
                self.newsNavigationController.pushViewController(controller, animated: false)
            }
            }.error { error in
                self.resultQueue.addOperationWithBlock {
                    self.newsNavigationController.popViewControllerAnimated(false)
                }
        }
    }
}
