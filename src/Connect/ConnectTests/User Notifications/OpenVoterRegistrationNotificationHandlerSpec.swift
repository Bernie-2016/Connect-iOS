import Quick
import Nimble

@testable import Connect

class OpenVoterRegistrationNotificationHandlerSpec: QuickSpec {
    override func spec() {
        describe("OpenVoterRegistrationNotificationHandler") {
            var subject: RemoteNotificationHandler!
            var voterRegistrationController: UINavigationController!
            var tabBarController: UITabBarController!
            var selectedTabController: UIViewController!

            var receivedFetchResult: UIBackgroundFetchResult!

            beforeEach {
                voterRegistrationController = UINavigationController()
                tabBarController = UITabBarController()
                selectedTabController = UIViewController()

                tabBarController.viewControllers = [selectedTabController, voterRegistrationController]
                tabBarController.selectedIndex = 0

                receivedFetchResult = nil

                subject = OpenVoterRegistrationNotificationHandler(
                    voterRegistrationController: voterRegistrationController,
                    tabBarController: tabBarController
                )
            }

            describe("handling a notification that will open the voter registration screen") {
                let userInfo: NotificationUserInfo = ["action": "openVoterRegistration"]

                it("ensures that the voter registration controller is the selected controller of the tab bar controller") {
                    subject.handleRemoteNotification(userInfo) { _ in }

                    expect(tabBarController.selectedViewController).to(beIdenticalTo(voterRegistrationController))
                }

                it("calls the completion handler") {
                    expect(receivedFetchResult).to(beNil())

                    subject.handleRemoteNotification(userInfo) { fetchResult in
                        receivedFetchResult = fetchResult
                    }

                    expect(receivedFetchResult) == UIBackgroundFetchResult.NewData
                }
            }

            describe("handling a notification that is not configured to open the voterregistration screen") {
                it("does nothing to the tab bar controller") {
                    var userInfo: NotificationUserInfo = ["action": "openVideo", "identifier": "youtube!"]
                    subject.handleRemoteNotification(userInfo) { _ in }

                    expect(tabBarController.selectedViewController) === selectedTabController

                    userInfo = NotificationUserInfo()
                    subject.handleRemoteNotification(userInfo) { _ in }

                    expect(tabBarController.selectedViewController) === selectedTabController
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
