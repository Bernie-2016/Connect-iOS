import Quick
import Nimble

@testable import Connect

class ShowNearbyEventsNotificationHandlerSpec: QuickSpec {
    override func spec() {
        describe("ShowNearbyEventsNotificationHandler") {
            var subject: RemoteNotificationHandler!
            var tabBarController: UITabBarController!
            var selectedTabController: UIViewController!
            var rootEventsController: UIViewController!
            var eventsNavigationController: UINavigationController!
            var nearbyEventsUseCase: MockNearbyEventsUseCase!
            var radiusDataSource: MockRadiusDataSource!
            var workerQueue: FakeOperationQueue!

            beforeEach {
                selectedTabController = UIViewController()
                rootEventsController = UIViewController()
                eventsNavigationController = UINavigationController(rootViewController: rootEventsController)

                tabBarController = UITabBarController()
                tabBarController.viewControllers = [selectedTabController, eventsNavigationController]
                tabBarController.selectedIndex = 0

                nearbyEventsUseCase = MockNearbyEventsUseCase()
                radiusDataSource = MockRadiusDataSource()
                workerQueue = FakeOperationQueue()

                subject = ShowNearbyEventsNotificationHandler(
                    eventsNavigationController: eventsNavigationController,
                    tabBarController: tabBarController,
                    nearbyEventsUseCase: nearbyEventsUseCase,
                    radiusDataSource: radiusDataSource,
                    workerQueue: workerQueue
                )
            }

            describe("handling a notification that will show nearby events") {
                let userInfo: NotificationUserInfo = ["action": "showNearbyEvents"]

                beforeEach { radiusDataSource.setDefaultRadiusMiles(666) }

                it("ensures that the navigation controller is the selected controller of the tab bar controller") {
                    subject.handleRemoteNotification(userInfo) { _ in }

                    expect(tabBarController.selectedViewController) === eventsNavigationController
                }

                it("pops to the root view controller") {
                    var i = 0
                    let limit = Int(arc4random_uniform(6) + 1)
                    while i < limit {
                        eventsNavigationController.pushViewController(UIViewController(), animated: false)
                        i = i + 1
                    }

                    subject.handleRemoteNotification(userInfo) { _ in }

                    expect(eventsNavigationController.topViewController) === rootEventsController
                }

                it("resets the nearby data source") {
                    subject.handleRemoteNotification(userInfo) { _ in }

                    expect(radiusDataSource.didResetToDefaultSearchRadius) == true
                }

                it("tells the use case to fetch nearby events with the default value on the worker queue") {
                    subject.handleRemoteNotification(userInfo) { _ in }

                    expect(nearbyEventsUseCase.didFetchNearbyEventsWithinRadius).to(beNil())

                    workerQueue.lastReceivedBlock()

                    expect(nearbyEventsUseCase.didFetchNearbyEventsWithinRadius) == 666
                }

                it("calls the completion handler on the worker queue") {
                    var receivedFetchResult: UIBackgroundFetchResult?

                    subject.handleRemoteNotification(userInfo) { fetchResult in
                        receivedFetchResult = fetchResult
                    }

                    expect(receivedFetchResult).to(beNil())

                    workerQueue.lastReceivedBlock()

                    expect(receivedFetchResult) == UIBackgroundFetchResult.NewData
                }
            }

            describe("handling a notification that is not configured to show nearby events") {
                let userInfo: NotificationUserInfo = ["action": "doSomethingElse"]

                it("does nothing to the tab bar controller") {
                    subject.handleRemoteNotification(userInfo) { _ in }

                    expect(tabBarController.selectedViewController) === selectedTabController
                }

                it("does not call the completion handler") {
                    var receivedFetchResult: UIBackgroundFetchResult?

                    subject.handleRemoteNotification(userInfo) { fetchResult in
                        receivedFetchResult = fetchResult
                    }

                    expect(receivedFetchResult).to(beNil())
                }
            }

            describe("handling a notification that lacks an action") {
                let userInfo: NotificationUserInfo = ["action": "doSomethingElse"]

                it("does nothing to the tab bar controller") {
                    let userInfo: NotificationUserInfo = [:]

                    subject.handleRemoteNotification(userInfo) { _ in }

                    expect(tabBarController.selectedViewController) === selectedTabController
                }

                it("does not call the completion handler") {
                    var receivedFetchResult: UIBackgroundFetchResult?

                    subject.handleRemoteNotification(userInfo) { fetchResult in
                        receivedFetchResult = fetchResult
                    }

                    expect(receivedFetchResult).to(beNil())
                }
            }
        }
    }
}
