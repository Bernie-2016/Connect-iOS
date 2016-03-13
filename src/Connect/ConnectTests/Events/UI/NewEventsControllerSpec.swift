import Quick
import Nimble
import CoreLocation

@testable import Connect

class NewEventsControllerSpec: QuickSpec {
    override func spec() {
        describe("NewEventsController") {
            var subject: NewEventsController!
            var interstitialController: UIViewController!
            var resultsController: UIViewController!
            var errorController: UIViewController!
            var nearbyEventsUseCase: MockNearbyEventsUseCase!
            var childControllerBuddy: MockChildControllerBuddy!
            var tabBarItemStylist: FakeTabBarItemStylist!

            beforeEach {
                interstitialController = UIViewController()
                resultsController = UIViewController()
                errorController = UIViewController()
                nearbyEventsUseCase = MockNearbyEventsUseCase()
                childControllerBuddy = MockChildControllerBuddy()
                tabBarItemStylist = FakeTabBarItemStylist()

                subject = NewEventsController(
                    interstitialController: interstitialController,
                    resultsController: resultsController,
                    errorController: errorController,
                    nearbyEventsUseCase: nearbyEventsUseCase,
                    childControllerBuddy: childControllerBuddy,
                    tabBarItemStylist: tabBarItemStylist
                )
            }


            it("has the correct tab bar title") {
                expect(subject.title).to(equal("Nearby"))
            }

            it("uses the tab bar item stylist to style its tab bar item") {
                expect(tabBarItemStylist.lastReceivedTabBarItem).to(beIdenticalTo(subject.tabBarItem))

                expect(tabBarItemStylist.lastReceivedTabBarImage).to(equal(UIImage(named: "eventsTabBarIconInactive")))
                expect(tabBarItemStylist.lastReceivedTabBarSelectedImage).to(equal(UIImage(named: "eventsTabBarIcon")))
            }

            describe("when the view loads") {
                it("adds the results container view as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.resultsView))
                }

                it("has the correct navigation item title") {
                    subject.view.layoutSubviews()

                    expect(subject.navigationItem.title).to(equal("Events Near Me"))
                }

                it("should set the back bar button item title correctly") {
                    subject.view.layoutSubviews()

                    expect(subject.navigationItem.backBarButtonItem?.title) == ""
                }

                it("initially adds the interstitial controller as a child controller in the results view") {
                    subject.view.layoutSubviews()

                    expect(childControllerBuddy.lastAddedViewController) === interstitialController
                    expect(childControllerBuddy.lastAddedParentViewController) === subject
                    expect(childControllerBuddy.lastAddedContainerView) === subject.resultsView
                }

                it("asks the nearby events use case to fetch events within the correct radius") {
                    subject.view.layoutSubviews()

                    // TODO find some way of setting this default radius across both
                    // the UI in the search bar and here
                    expect(nearbyEventsUseCase.didFetchNearbyEventsWithinRadius) == 10
                }
            }

            describe("as a nearby events use case observer") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                context("when the use case finds nearby events") {
                    it("swaps the interstitial controller for the results controller") {
                        let event = TestUtils.eventWithName("nearby event")
                        let eventSearchResult = EventSearchResult(events: [event])
                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)

                        expect(childControllerBuddy.lastOldSwappedController) === interstitialController
                        expect(childControllerBuddy.lastNewSwappedController) === resultsController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }

                context("when the use case finds no nearby events") {
                    it("swaps the interstitial controller for the results controller") {
                        nearbyEventsUseCase.simulateFindingNoEvents()

                        expect(childControllerBuddy.lastOldSwappedController) === interstitialController
                        expect(childControllerBuddy.lastNewSwappedController) === resultsController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }

                context("when the use case encounters an error") {
                    it("swaps the interstitial controller for the error controller") {
                        let error = NearbyEventsUseCaseError.FindingLocationError(.PermissionsError)
                        nearbyEventsUseCase.simulateFailingToFindEvents(error)

                        expect(childControllerBuddy.lastOldSwappedController) === interstitialController
                        expect(childControllerBuddy.lastNewSwappedController) === errorController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }
            }
        }
    }
}

private class MockChildControllerBuddy: ChildControllerBuddy {
    var lastOldSwappedController: UIViewController!
    var lastNewSwappedController: UIViewController!
    var lastParentSwappedController: UIViewController!
    var lastCompletionHandler: ChildControllerBuddySwapCompletionHandler!

    func swap(old: UIViewController, new: UIViewController, parent: UIViewController, completionHandler: ChildControllerBuddySwapCompletionHandler) {
        lastOldSwappedController = old
        lastNewSwappedController = new
        lastParentSwappedController = parent
        lastCompletionHandler = completionHandler
    }

    var lastAddedViewController: UIViewController?
    var lastAddedParentViewController: UIViewController?
    var lastAddedContainerView: UIView?
    func add(new: UIViewController, to parent: UIViewController, containIn: UIView) {
        lastAddedViewController = new
        lastAddedParentViewController = parent
        lastAddedContainerView = containIn
    }
}

