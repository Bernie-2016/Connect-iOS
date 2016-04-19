import Quick
import Nimble

@testable import Connect

class OpenActionAlertNotificationHandlerSpec: QuickSpec {
    override func spec() {
        describe("OpenActionAlertNotificationHandler") {
            var subject: RemoteNotificationHandler!
            var actionsNavigationController: UINavigationController!
            var tabBarController: UITabBarController!
            var selectedTabController: UIViewController!

            var receivedFetchResult: UIBackgroundFetchResult!

            beforeEach {
                actionsNavigationController = UINavigationController()
                tabBarController = UITabBarController()
                selectedTabController = UIViewController()

                tabBarController.viewControllers = [selectedTabController, actionsNavigationController]
                tabBarController.selectedIndex = 0

                receivedFetchResult = nil

                subject = OpenActionAlertNotificationHandler(
                    actionsNavigationController: actionsNavigationController,
                    tabBarController: tabBarController
                )
            }

            describe("handling a notification that will open an action alert") {
                let userInfo: NotificationUserInfo = ["action": "openActionAlert", "identifier": "do-it-naaoow"]

                it("ensures that the navigation controller is the selected controller of the tab bar controller") {
                    subject.handleRemoteNotification(userInfo) { _ in }

                    expect(tabBarController.selectedViewController).to(beIdenticalTo(actionsNavigationController))
                }

                it("calls the completion handler") {
                    expect(receivedFetchResult).to(beNil())

                    subject.handleRemoteNotification(userInfo) { fetchResult in
                        receivedFetchResult = fetchResult
                    }

                    expect(receivedFetchResult) == UIBackgroundFetchResult.NewData
                }
            }

            describe("handling a notification that is not configured to open an action alert") {
                it("does nothing to the tab bar controller") {
                    var userInfo: NotificationUserInfo = ["action": "openVideo", "identifier": "youtube!"]
                    subject.handleRemoteNotification(userInfo) { _ in }

                    expect(tabBarController.selectedViewController) === selectedTabController

                    userInfo = NotificationUserInfo()
                    subject.handleRemoteNotification(userInfo) { _ in }

                    expect(tabBarController.selectedViewController) === selectedTabController
                }

                it("does not calls the completion handler") {
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
