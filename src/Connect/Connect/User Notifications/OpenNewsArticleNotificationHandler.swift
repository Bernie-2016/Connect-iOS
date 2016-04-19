import Foundation


extension RemoteNotificationHandlerKeys.ActionTypes {
    static let OpenNewsArticle = "openNewsArticle"
}

class OpenNewsArticleNotificationHandler: RemoteNotificationHandler {
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

    func handleRemoteNotification(notificationUserInfo: NotificationUserInfo, fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        guard let action = notificationUserInfo[RemoteNotificationHandlerKeys.ActionKey] as? String else {
            return
        }

        if action != RemoteNotificationHandlerKeys.ActionTypes.OpenNewsArticle { return }

        guard let identifier = notificationUserInfo[RemoteNotificationHandlerKeys.IdentifierKey] as? String else {
            completionHandler(.Failed)
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
                completionHandler(.NewData)
            }
            }.error { error in
                self.resultQueue.addOperationWithBlock {
                    self.newsNavigationController.popToRootViewControllerAnimated(false)
                    completionHandler(.Failed)
                }
        }
    }
}
