import Quick
import Nimble

@testable import Connect

class OpenActionAlertNotificationHandlerSpec: QuickSpec {
    override func spec() {
        describe("OpenActionAlertNotificationHandler") {
            var subject: UserNotificationHandler!
            var actionsNavigationController: UINavigationController!
            var existingActionController: UIViewController!
            var interstitialController: UIViewController!
            var tabBarController: UITabBarController!
            var selectedTabController: UIViewController!
            var actionAlertControllerProvider: FakeActionAlertControllerProvider!
            var actionAlertService: FakeActionAlertService!

            beforeEach {
                existingActionController = UIViewController()
                actionsNavigationController = UINavigationController(rootViewController: existingActionController)
                interstitialController = UIViewController()
                tabBarController = UITabBarController()
                selectedTabController = UIViewController()
                actionAlertControllerProvider = FakeActionAlertControllerProvider()
                actionAlertService = FakeActionAlertService()

                tabBarController.viewControllers = [selectedTabController, actionsNavigationController]
                tabBarController.selectedIndex = 0

                subject = OpenActionAlertNotificationHandler(
                    actionsNavigationController: actionsNavigationController,
                    interstitialController: interstitialController,
                    tabBarController: tabBarController,
                    actionAlertControllerProvider: actionAlertControllerProvider,
                    actionAlertService: actionAlertService
                )
            }

            describe("handling a notification that will open an action alert") {
                let userInfo: NotificationUserInfo = ["action": "openActionAlert", "identifier": "do-it-naaoow"]

                it("pushes the interstitial controller onto the navigation controller") {
                    subject.handleRemoteNotification(userInfo)

                    expect(actionsNavigationController.topViewController).to(beIdenticalTo(interstitialController))
                }

                it("ensures that the navigation controller is the selected controller of the tab bar controller") {
                    subject.handleRemoteNotification(userInfo)

                    expect(tabBarController.selectedViewController).to(beIdenticalTo(actionsNavigationController))
                }

                it("asks the news service for an article with that identifier") {
                    subject.handleRemoteNotification(userInfo)

                    expect(actionAlertService.lastReceivedIdentifier).to(equal("do-it-naaoow"))
                }

                context("when the action alert is returned") {
                    beforeEach { subject.handleRemoteNotification(userInfo) }

                    it("replaces the interstitial controller with a controller configured for the article") {
                        let actionAlert = TestUtils.actionAlert()
                        actionAlertService.lastReturnedActionAlertPromise.resolve(actionAlert)

                        expect(actionAlertControllerProvider.lastActionAlertReceived).to(equal(actionAlert))

                        let expectedController = actionAlertControllerProvider.returnedController
                        expect(actionsNavigationController.topViewController).to(beIdenticalTo(expectedController))
                        expect(actionsNavigationController.viewControllers).to(equal([existingActionController, expectedController]))
                    }
                }

                context("when the action alert fails to be returned") {
                    beforeEach { subject.handleRemoteNotification(userInfo) }

                    it("it pops the interstitial controller from the navigation controller") {
                        let error = ActionAlertRepositoryError.InvalidJSON(jsonObject: [])
                        actionAlertService.lastReturnedActionAlertPromise.reject(error)

                        expect(actionsNavigationController.topViewController).to(beIdenticalTo(existingActionController))
                    }
                }
            }

            describe("handling a notification that is configured to open am action alert but lacks an identifier") {
                it("does nothing to the actions navigation controller") {
                    var userInfo: NotificationUserInfo = ["action": "openActionAlert"]
                    subject.handleRemoteNotification(userInfo)

                    expect(actionsNavigationController.topViewController).to(beIdenticalTo(existingActionController))

                    userInfo = NotificationUserInfo()
                    subject.handleRemoteNotification(userInfo)

                    expect(actionsNavigationController.topViewController).to(beIdenticalTo(existingActionController))
                }

            }
            describe("handling a notification that is not configured to open an action alert") {
                it("does nothing to the actions navigation controller") {
                    var userInfo: NotificationUserInfo = ["action": "openVideo", "identifier": "youtube!"]
                    subject.handleRemoteNotification(userInfo)

                    expect(actionsNavigationController.topViewController).to(beIdenticalTo(existingActionController))

                    userInfo = NotificationUserInfo()
                    subject.handleRemoteNotification(userInfo)

                    expect(actionsNavigationController.topViewController).to(beIdenticalTo(existingActionController))
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
