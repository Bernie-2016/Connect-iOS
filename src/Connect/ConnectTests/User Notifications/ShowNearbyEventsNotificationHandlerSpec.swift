import Quick
import Nimble

@testable import Connect

class ShowNearbyEventsNotificationHandlerSpec: QuickSpec {
    override func spec() {
        describe("ShowNearbyEventsNotificationHandler") {
            var subject: UserNotificationHandler!
            var tabBarController: UITabBarController!
            var selectedTabController: UIViewController!
            var eventsNavigationController: UIViewController!
            var nearbyEventsUseCase: MockNearbyEventsUseCase!
            var radiusDataSource: MockRadiusDataSource!

            beforeEach {
                selectedTabController = UIViewController()
                eventsNavigationController = UIViewController()

                tabBarController = UITabBarController()
                tabBarController.viewControllers = [selectedTabController, eventsNavigationController]
                tabBarController.selectedIndex = 0

                nearbyEventsUseCase = MockNearbyEventsUseCase()
                radiusDataSource = MockRadiusDataSource()

                subject = ShowNearbyEventsNotificationHandler(
                    eventsNavigationController: eventsNavigationController,
                    tabBarController: tabBarController,
                    nearbyEventsUseCase: nearbyEventsUseCase,
                    radiusDataSource: radiusDataSource
                )
            }

            describe("handling a notification that will show nearby events") {
                let userInfo: NotificationUserInfo = ["action": "showNearbyEvents"]

                beforeEach { radiusDataSource.setDefaultRadiusMiles(666) }

                it("ensures that the navigation controller is the selected controller of the tab bar controller") {
                    subject.handleRemoteNotification(userInfo)

                    expect(tabBarController.selectedViewController) === eventsNavigationController
                }

                it("resets the nearby data source") {
                    subject.handleRemoteNotification(userInfo)

                    expect(radiusDataSource.didResetToDefaultSearchRadius) == true
                }

                it("tells the use case to fetch nearby events with the default value") {
                    subject.handleRemoteNotification(userInfo)

                    expect(nearbyEventsUseCase.didFetchNearbyEventsWithinRadius) == 666
                }
            }

            describe("handling a notification that is not configured to show nearby events") {
                it("does nothing to the tab bar controller") {
                    let userInfo: NotificationUserInfo = ["action": "doSomethingElse"]

                    subject.handleRemoteNotification(userInfo)

                    expect(tabBarController.selectedViewController) === selectedTabController
                }
            }

            describe("handling a notification that lacks an action") {
                it("does nothing to the tab bar controller") {
                    let userInfo: NotificationUserInfo = [:]

                    subject.handleRemoteNotification(userInfo)

                    expect(tabBarController.selectedViewController) === selectedTabController
                }
            }
        }
    }
}