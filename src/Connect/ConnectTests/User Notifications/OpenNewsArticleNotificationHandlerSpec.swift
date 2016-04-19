import Quick
import Nimble

@testable import Connect

class OpenNewsArticleNotificationHandlerSpec: QuickSpec {
    override func spec() {
        describe("OpenNewsArticleNotificationHandler") {
            var subject: RemoteNotificationHandler!
            var newsNavigationController: UINavigationController!
            var existingNewsController: UIViewController!
            var interstitialController: UIViewController!
            var tabBarController: UITabBarController!
            var selectedTabController: UIViewController!
            var newsFeedItemControllerProvider: FakeNewsFeedItemControllerProvider!
            var newsArticleService: FakeNewsArticleService!
            var resultQueue: FakeOperationQueue!

            var receivedFetchResult: UIBackgroundFetchResult!

            beforeEach {
                existingNewsController = UIViewController()
                newsNavigationController = UINavigationController(rootViewController: existingNewsController)
                interstitialController = UIViewController()
                tabBarController = UITabBarController()
                selectedTabController = UIViewController()
                newsFeedItemControllerProvider = FakeNewsFeedItemControllerProvider()
                newsArticleService = FakeNewsArticleService()
                resultQueue = FakeOperationQueue()

                tabBarController.viewControllers = [selectedTabController, newsNavigationController]
                tabBarController.selectedIndex = 0

                receivedFetchResult = nil

                subject = OpenNewsArticleNotificationHandler(
                    newsNavigationController: newsNavigationController,
                    interstitialController: interstitialController,
                    tabBarController: tabBarController,
                    newsFeedItemControllerProvider: newsFeedItemControllerProvider,
                    newsArticleService: newsArticleService,
                    resultQueue: resultQueue
                )
            }

            describe("handling a notification that will open a news article") {
                let userInfo: NotificationUserInfo = ["action": "openNewsArticle", "identifier": "some-cool-news"]

                it("pushes the interstitial controller onto the navigation controller") {
                    subject.handleRemoteNotification(userInfo) { _ in }

                    expect(newsNavigationController.topViewController).to(beIdenticalTo(interstitialController))
                }

                it("ensures that the navigation controller is the selected controller of the tab bar controller") {
                    subject.handleRemoteNotification(userInfo) { _ in }

                    expect(tabBarController.selectedViewController).to(beIdenticalTo(newsNavigationController))
                }

                it("asks the news service for an article with that identifier") {
                    subject.handleRemoteNotification(userInfo) { _ in }

                    expect(newsArticleService.lastReceivedIdentifier).to(equal("some-cool-news"))
                }

                context("when the article is returned") {
                    beforeEach { subject.handleRemoteNotification(userInfo) { fetchResult in
                        receivedFetchResult = fetchResult
                        }
                    }

                    it("replaces the interstitial controller with a controller configured for the article on the result queue") {
                        let newsArticle = TestUtils.newsArticle()
                        newsArticleService.lastReturnedPromise.resolve(newsArticle)

                        expect(newsFeedItemControllerProvider.lastNewsFeedItem as? NewsArticle).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(newsFeedItemControllerProvider.lastNewsFeedItem as? NewsArticle).to(beIdenticalTo(newsArticle))

                        let expectedController = newsFeedItemControllerProvider.controller
                        expect(newsNavigationController.topViewController).to(beIdenticalTo(expectedController))
                        expect(newsNavigationController.viewControllers) == [existingNewsController, expectedController]
                    }

                    it("calls the completion handler") {
                        let newsArticle = TestUtils.newsArticle()
                        newsArticleService.lastReturnedPromise.resolve(newsArticle)
                        resultQueue.lastReceivedBlock()

                        expect(receivedFetchResult) == UIBackgroundFetchResult.NewData
                    }
                }

                context("when the article fails to be returned") {
                    beforeEach { subject.handleRemoteNotification(userInfo) { fetchResult in
                        receivedFetchResult = fetchResult
                        }
                    }

                    it("it pops the interstitial controller from the navigation controller on the result queue") {
                        let error = NewsArticleRepositoryError.NoMatchingNewsArticle(identifier: "bowlax")
                        newsArticleService.lastReturnedPromise.reject(error)

                        expect(newsNavigationController.topViewController).to(beIdenticalTo(interstitialController))

                        resultQueue.lastReceivedBlock()

                        expect(newsNavigationController.topViewController).to(beIdenticalTo(existingNewsController))
                    }

                    it("calls the completion handler") {
                        let error = NewsArticleRepositoryError.NoMatchingNewsArticle(identifier: "bowlax")
                        newsArticleService.lastReturnedPromise.reject(error)

                        resultQueue.lastReceivedBlock()

                        expect(receivedFetchResult) == UIBackgroundFetchResult.Failed
                    }
                }
            }

            describe("handling a notification that is configured to open a news article but lacks an identifier") {
                it("does nothing to the news navigation controller") {
                    var userInfo: NotificationUserInfo = ["action": "openNewsArticle"]
                    subject.handleRemoteNotification(userInfo) { _ in }

                    expect(newsNavigationController.topViewController).to(beIdenticalTo(existingNewsController))

                    userInfo = NotificationUserInfo()
                    subject.handleRemoteNotification(userInfo) { _ in }

                    expect(newsNavigationController.topViewController).to(beIdenticalTo(existingNewsController))
                }

                it("calls the completion handler") {
                    let userInfo: NotificationUserInfo = ["action": "openNewsArticle"]
                    subject.handleRemoteNotification(userInfo) { fetchResult in
                        receivedFetchResult = fetchResult
                    }


                    expect(receivedFetchResult) == UIBackgroundFetchResult.Failed
                }

            }
            describe("handling a notification that is not configured to open a news article") {
                it("does nothing to the news navigation controller") {
                    var userInfo: NotificationUserInfo = ["action": "openVideo", "identifier": "youtube!"]
                    subject.handleRemoteNotification(userInfo) { _ in }

                    expect(newsNavigationController.topViewController).to(beIdenticalTo(existingNewsController))

                    userInfo = NotificationUserInfo()
                    subject.handleRemoteNotification(userInfo) { _ in }

                    expect(newsNavigationController.topViewController).to(beIdenticalTo(existingNewsController))
                }

                it("does not call the completion handler") {
                    var userInfo: NotificationUserInfo = ["action": "openVideo", "identifier": "youtube!"]
                    subject.handleRemoteNotification(userInfo) { fetchResult in
                        receivedFetchResult = fetchResult
                    }

                    expect(receivedFetchResult).to(beNil())

                    userInfo = NotificationUserInfo()
                    subject.handleRemoteNotification(userInfo) { fetchResult in
                        receivedFetchResult = fetchResult
                    }

                    expect(receivedFetchResult).to(beNil())
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
