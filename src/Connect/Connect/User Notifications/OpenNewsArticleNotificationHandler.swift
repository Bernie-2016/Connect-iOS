import Foundation


extension UserNotificationHandlerKeys.ActionTypes {
    static let OpenNewsArticle = "openNewsArticle"
}

class OpenNewsArticleNotificationHandler: UserNotificationHandler {
    let newsNavigationController: UINavigationController
    let interstitialController: UIViewController
    let tabBarController: UITabBarController
    let newsFeedItemControllerProvider: NewsFeedItemControllerProvider
    let newsArticleService: NewsArticleService
    let resultQueue: NSOperationQueue

    init(newsNavigationController: UINavigationController,
         interstitialController: UIViewController,
         tabBarController: UITabBarController,
         newsFeedItemControllerProvider: NewsFeedItemControllerProvider,
         newsArticleService: NewsArticleService,
         resultQueue: NSOperationQueue) {
        self.newsNavigationController = newsNavigationController
        self.interstitialController = interstitialController
        self.tabBarController = tabBarController
        self.newsFeedItemControllerProvider = newsFeedItemControllerProvider
        self.newsArticleService = newsArticleService
        self.resultQueue = resultQueue
    }

    func handleRemoteNotification(notificationUserInfo: NotificationUserInfo) {
        guard let action = notificationUserInfo[UserNotificationHandlerKeys.ActionKey] as? String else {
            return
        }

        if action != UserNotificationHandlerKeys.ActionTypes.OpenNewsArticle { return }

        guard let identifier = notificationUserInfo[UserNotificationHandlerKeys.IdentifierKey] as? String else {
            return
        }

        tabBarController.selectedViewController = newsNavigationController
        newsNavigationController.pushViewController(interstitialController, animated: false)

        let newsArticleFuture = newsArticleService.fetchNewsArticle(identifier)

        newsArticleFuture.then { newsArticle in
            self.resultQueue.addOperationWithBlock {
                let controller = self.newsFeedItemControllerProvider.provideInstanceWithNewsFeedItem(newsArticle)
                self.newsNavigationController.popToRootViewControllerAnimated(false)
                self.newsNavigationController.pushViewController(controller, animated: false)
            }
            }.error { error in
                self.resultQueue.addOperationWithBlock {
                    self.newsNavigationController.popToRootViewControllerAnimated(false)
                }
        }
    }
}
