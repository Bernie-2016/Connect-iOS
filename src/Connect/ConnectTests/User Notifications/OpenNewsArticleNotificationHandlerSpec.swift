import Quick
import Nimble

@testable import Connect

class OpenNewsArticleNotificationHandlerSpec: QuickSpec {
    override func spec() {
        describe("OpenNewsArticleNotificationHandler") {
            var subject: UserNotificationHandler!
            var newsNavigationController: UINavigationController!
            var existingNewsController: UIViewController!
            var interstitialController: UIViewController!
            var tabBarController: UITabBarController!
            var selectedTabController: UIViewController!
            var newsFeedItemControllerProvider: FakeNewsFeedItemControllerProvider!
            var newsArticleService: FakeNewsArticleService!

            beforeEach {
                existingNewsController = UIViewController()
                newsNavigationController = UINavigationController(rootViewController: existingNewsController)
                interstitialController = UIViewController()
                tabBarController = UITabBarController()
                selectedTabController = UIViewController()
                newsFeedItemControllerProvider = FakeNewsFeedItemControllerProvider()
                newsArticleService = FakeNewsArticleService()

                tabBarController.viewControllers = [selectedTabController, newsNavigationController]
                tabBarController.selectedIndex = 0

                subject = OpenNewsArticleNotificationHandler(
                    newsNavigationController: newsNavigationController,
                    interstitialController: interstitialController,
                    tabBarController: tabBarController,
                    newsFeedItemControllerProvider: newsFeedItemControllerProvider,
                    newsArticleService: newsArticleService
                )
            }

            describe("handling a notification that will open a news article") {
                let userInfo: NotificationUserInfo = ["action": "openNewsArticle", "identifier": "some-cool-news"]

                it("pushes the interstitial controller onto the navigation controller") {
                    subject.handleRemoteNotification(userInfo)

                    expect(newsNavigationController.topViewController).to(beIdenticalTo(interstitialController))
                }

                it("ensures that the navigation controller is the selected controller of the tab bar controller") {
                    subject.handleRemoteNotification(userInfo)

                    expect(tabBarController.selectedViewController).to(beIdenticalTo(newsNavigationController))
                }

                it("asks the news service for an article with that identifier") {
                    subject.handleRemoteNotification(userInfo)

                    expect(newsArticleService.lastReceivedIdentifier).to(equal("some-cool-news"))
                }

                context("when the article is returned") {
                    beforeEach { subject.handleRemoteNotification(userInfo) }

                    it("replaces the interstitial controller with a controller configured for the article") {
                        let newsArticle = TestUtils.newsArticle()
                        newsArticleService.lastReturnedPromise.resolve(newsArticle)

                        expect(newsFeedItemControllerProvider.lastNewsFeedItem as? NewsArticle).to(beIdenticalTo(newsArticle))

                        let expectedController = newsFeedItemControllerProvider.controller
                        expect(newsNavigationController.topViewController).to(beIdenticalTo(expectedController))
                        expect(newsNavigationController.viewControllers) == [existingNewsController, expectedController]
                    }
                }

                context("when the article fails to be returned") {
                    beforeEach { subject.handleRemoteNotification(userInfo) }

                    it("it pops the interstitial controller from the navigation controller") {
                        let error = NewsArticleRepositoryError.NoMatchingNewsArticle(identifier: "bowlax")
                        newsArticleService.lastReturnedPromise.reject(error)

                        expect(newsNavigationController.topViewController).to(beIdenticalTo(existingNewsController))
                    }
                }
            }

            describe("handling a notification that is configured to open a news article but lacks an identifier") {
                it("does nothing to the news navigation controller") {
                    var userInfo: NotificationUserInfo = ["action": "openNewsArticle"]
                    subject.handleRemoteNotification(userInfo)

                    expect(newsNavigationController.topViewController).to(beIdenticalTo(existingNewsController))

                    userInfo = NotificationUserInfo()
                    subject.handleRemoteNotification(userInfo)

                    expect(newsNavigationController.topViewController).to(beIdenticalTo(existingNewsController))
                }

            }
            describe("handling a notification that is not configured to open a news article") {
                it("does nothing to the news navigation controller") {
                    var userInfo: NotificationUserInfo = ["action": "openVideo", "identifier": "youtube!"]
                    subject.handleRemoteNotification(userInfo)

                    expect(newsNavigationController.topViewController).to(beIdenticalTo(existingNewsController))

                    userInfo = NotificationUserInfo()
                    subject.handleRemoteNotification(userInfo)

                    expect(newsNavigationController.topViewController).to(beIdenticalTo(existingNewsController))
                }
            }
        }
    }
}

private class FakeNewsArticleService: NewsArticleService {
    var lastReturnedPromise: NewsArticlePromise!
    var lastReceivedIdentifier: NewsArticleIdentifier!

    private func fetchNewsArticle(identifier: NewsArticleIdentifier) -> NewsArticleFuture {
        lastReturnedPromise = NewsArticlePromise()

        lastReceivedIdentifier = identifier

        return lastReturnedPromise.future
    }
}
