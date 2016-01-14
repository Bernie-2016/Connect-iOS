import Foundation


extension UserNotificationHandlerKeys.ActionTypes {
    static let OpenNewsArticle = "openNewsArticle"
}

class OpenNewsArticleNotificationHandler: UserNotificationHandler {
    let newsNavigationController: UINavigationController
    let interstitialController: UIViewController
    let newsFeedItemControllerProvider: NewsFeedItemControllerProvider
    let newsArticleService: NewsArticleService

    init(newsNavigationController: UINavigationController,
        interstitialController: UIViewController,
        newsFeedItemControllerProvider: NewsFeedItemControllerProvider,
        newsArticleService: NewsArticleService) {
        self.newsNavigationController = newsNavigationController
        self.interstitialController = interstitialController
        self.newsFeedItemControllerProvider = newsFeedItemControllerProvider
        self.newsArticleService = newsArticleService
    }

    func handleRemoteNotification(notificationUserInfo: NotificationUserInfo) {
        guard let action = notificationUserInfo[UserNotificationHandlerKeys.ActionKey] as? String else {
            return
        }

        if action != UserNotificationHandlerKeys.ActionTypes.OpenNewsArticle { return }

        guard let identifier = notificationUserInfo[UserNotificationHandlerKeys.IdentifierKey] as? String else {
            return
        }

        newsNavigationController.pushViewController(interstitialController, animated: false)

        let newsArticleFuture = newsArticleService.fetchNewsArticle(identifier)

        newsArticleFuture.then { newsArticle in
            let controller = self.newsFeedItemControllerProvider.provideInstanceWithNewsFeedItem(newsArticle)
            self.newsNavigationController.popViewControllerAnimated(false)
            self.newsNavigationController.pushViewController(controller, animated: false)
            }.error { error in
            self.newsNavigationController.popViewControllerAnimated(false)
        }
    }
}
