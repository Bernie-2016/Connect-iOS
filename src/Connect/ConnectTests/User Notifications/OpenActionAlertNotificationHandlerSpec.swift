import Quick
import Nimble

@testable import Connect

class OpenActionAlertNotificationHandlerSpec: QuickSpec {
    override func spec() {
        describe("OpenActionAlertNotificationHandler") {
            var subject: UserNotificationHandler!
            var actionsNavigationController: UINavigationController!
            var tabBarController: UITabBarController!
            var selectedTabController: UIViewController!

            beforeEach {
                actionsNavigationController = UINavigationController()
                tabBarController = UITabBarController()
                selectedTabController = UIViewController()

                tabBarController.viewControllers = [selectedTabController, actionsNavigationController]
                tabBarController.selectedIndex = 0

                subject = OpenActionAlertNotificationHandler(
                    actionsNavigationController: actionsNavigationController,
                    tabBarController: tabBarController
                )
            }

            describe("handling a notification that will open an action alert") {
                let userInfo: NotificationUserInfo = ["action": "openActionAlert", "identifier": "do-it-naaoow"]

                it("ensures that the navigation controller is the selected controller of the tab bar controller") {
                    subject.handleRemoteNotification(userInfo)

                    expect(tabBarController.selectedViewController).to(beIdenticalTo(actionsNavigationController))
                }
            }

            describe("handling a notification that is not configured to open an action alert") {
                it("does nothing to the tab bar controller") {
                    var userInfo: NotificationUserInfo = ["action": "openVideo", "identifier": "youtube!"]
                    subject.handleRemoteNotification(userInfo)

                    expect(tabBarController.selectedViewController) === selectedTabController

                    userInfo = NotificationUserInfo()
                    subject.handleRemoteNotification(userInfo)

                    expect(tabBarController.selectedViewController) === selectedTabController
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
