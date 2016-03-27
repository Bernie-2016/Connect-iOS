import Quick
import Nimble
import CoreLocation

@testable import Connect

class EventsControllerSpec: QuickSpec {
    override func spec() {
        describe("EventsController") {
            var subject: EventsController!
            var searchBarController: UIViewController!
            var interstitialController: UIViewController!
            var resultsController: UIViewController!
            var noResultsController: UIViewController!
            var errorController: UIViewController!
            var nearbyEventsUseCase: MockNearbyEventsUseCase!
            var eventsNearAddressUseCase: MockEventsNearAddressUseCase!
            var childControllerBuddy: MockChildControllerBuddy!
            var tabBarItemStylist: FakeTabBarItemStylist!
            var radiusDataSource: MockRadiusDataSource!
            var workerQueue: FakeOperationQueue!
            var resultQueue: FakeOperationQueue!

            var navigationController: UINavigationController!

            beforeEach {
                searchBarController = UIViewController()
                interstitialController = UIViewController()
                resultsController = UIViewController()
                noResultsController = UIViewController()
                errorController = UIViewController()
                nearbyEventsUseCase = MockNearbyEventsUseCase()
                eventsNearAddressUseCase = MockEventsNearAddressUseCase()
                childControllerBuddy = MockChildControllerBuddy()
                tabBarItemStylist = FakeTabBarItemStylist()
                radiusDataSource = MockRadiusDataSource()
                workerQueue = FakeOperationQueue()
                resultQueue = FakeOperationQueue()

                subject = EventsController(
                    searchBarController: searchBarController,
                    interstitialController: interstitialController,
                    resultsController: resultsController,
                    noResultsController: noResultsController,
                    errorController: errorController,
                    nearbyEventsUseCase: nearbyEventsUseCase,
                    eventsNearAddressUseCase: eventsNearAddressUseCase,
                    childControllerBuddy: childControllerBuddy,
                    tabBarItemStylist: tabBarItemStylist,
                    radiusDataSource: radiusDataSource,
                    workerQueue: workerQueue,
                    resultQueue: resultQueue
                )

                navigationController = UINavigationController(rootViewController: subject)
            }

            it("has the correct tab bar title") {
                expect(subject.title) == "Events"
            }

            it("uses the tab bar item stylist to style its tab bar item") {
                expect(tabBarItemStylist.lastReceivedTabBarItem).to(beIdenticalTo(subject.tabBarItem))

                expect(tabBarItemStylist.lastReceivedTabBarImage).to(equal(UIImage(named: "eventsTabBarIconInactive")))
                expect(tabBarItemStylist.lastReceivedTabBarSelectedImage).to(equal(UIImage(named: "eventsTabBarIcon")))
            }

            describe("when the view appears") {
                it("hides the nav bar") {
                    subject.viewWillAppear(false)

                    expect(navigationController.navigationBarHidden) == true
                }
            }

            describe("when the view loads") {
                it("adds the results container view as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.resultsView))
                }

                it("adds the search bar view as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.searchBarView))
                }

                it("has the correct navigation item title") {
                    subject.view.layoutSubviews()

                    expect(subject.navigationItem.title).to(equal("Events Near Me"))
                }

                it("should set the back bar button item title correctly") {
                    subject.view.layoutSubviews()

                    expect(subject.navigationItem.backBarButtonItem?.title) == ""
                }

                it("adds the search bar controller as a child controller in the search bar view") {
                    subject.view.layoutSubviews()

                    let addCall = childControllerBuddy.addCalls.first!
                    expect(addCall.addController) === searchBarController
                    expect(addCall.parentController) === subject
                    expect(addCall.containerView) === subject.searchBarView
                }

                it("initially adds the interstitial controller as a child controller in the results view") {
                    subject.view.layoutSubviews()

                    let addCall = childControllerBuddy.addCalls.last!
                    expect(addCall.addController) === interstitialController
                    expect(addCall.parentController) === subject
                    expect(addCall.containerView) === subject.resultsView
                }

                it("asks the nearby events use case to fetch events within the radius from the radius data source on the worker queue") {
                    subject.view.layoutSubviews()

                    expect(nearbyEventsUseCase.didFetchNearbyEventsWithinRadius).to(beNil())

                    radiusDataSource.returnedCurrentMilesValue = 42

                    workerQueue.lastReceivedBlock()

                    expect(nearbyEventsUseCase.didFetchNearbyEventsWithinRadius) == 42
                }
            }

            describe("as a nearby events use case observer") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                context("when the use case finds nearby events") {
                    it("swaps the interstitial controller for the results controller on the results queue") {
                        let event = TestUtils.eventWithName("nearby event")
                        let eventSearchResult = EventSearchResult(events: [event])
                        nearbyEventsUseCase.simulateFindingEvents(eventSearchResult)

                        expect(childControllerBuddy.lastOldSwappedController).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(childControllerBuddy.lastOldSwappedController) === interstitialController
                        expect(childControllerBuddy.lastNewSwappedController) === resultsController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }

                context("when the use case finds no nearby events") {
                    it("swaps the interstitial controller for the results controller on the results queue") {
                        nearbyEventsUseCase.simulateFindingNoEvents()

                        expect(childControllerBuddy.lastOldSwappedController).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(childControllerBuddy.lastOldSwappedController) === interstitialController
                        expect(childControllerBuddy.lastNewSwappedController) === noResultsController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }

                context("when the use case encounters an error") {
                    it("swaps the interstitial controller for the error controller on the results queue") {
                        let error = NearbyEventsUseCaseError.FindingLocationError(.PermissionsError)
                        nearbyEventsUseCase.simulateFailingToFindEvents(error)

                        expect(childControllerBuddy.lastOldSwappedController).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(childControllerBuddy.lastOldSwappedController) === interstitialController
                        expect(childControllerBuddy.lastNewSwappedController) === errorController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }
            }

            describe("as an events near address use case observer") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                context("when the use case begins fetching events") {
                    beforeEach {
                        childControllerBuddy.reset()

                        let error = NearbyEventsUseCaseError.FindingLocationError(.PermissionsError)
                        nearbyEventsUseCase.simulateFailingToFindEvents(error)
                        resultQueue.lastReceivedBlock()
                    }

                    it("swaps that controller for the interstitial controller") {
                        eventsNearAddressUseCase.simulateStartOfFetch()

                        expect(childControllerBuddy.lastOldSwappedController) === interstitialController
                        expect(childControllerBuddy.lastNewSwappedController) === errorController
                        expect(childControllerBuddy.lastParentSwappedController) === subject

                    }
                }

                context("when the use case finds events") {
                    beforeEach {
                        childControllerBuddy.reset()

                        let error = NearbyEventsUseCaseError.FindingLocationError(.PermissionsError)
                        nearbyEventsUseCase.simulateFailingToFindEvents(error)
                        resultQueue.lastReceivedBlock()
                    }

                    it("swaps the currently shown results view for the results controller on the results queue") {
                        let event = TestUtils.eventWithName("nearby event")
                        let eventSearchResult = EventSearchResult(events: [event])
                        eventsNearAddressUseCase.simulateFindingEvents(eventSearchResult)

                        resultQueue.lastReceivedBlock()

                        expect(childControllerBuddy.lastOldSwappedController) === errorController
                        expect(childControllerBuddy.lastNewSwappedController) === resultsController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }

                context("when the use case finds no events near an address") {
                    it("swaps the currently shown results view for the results controller on the results queue") {
                        eventsNearAddressUseCase.simulateFindingNoEvents()

                        expect(childControllerBuddy.lastOldSwappedController).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(childControllerBuddy.lastOldSwappedController) === interstitialController
                        expect(childControllerBuddy.lastNewSwappedController) === noResultsController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }

                context("when the use case encounters an error") {
                    it("swaps the currently shown results view controller for the error controller on the results queue") {
                        let underlyingError = EventRepositoryError.InvalidJSONError(jsonObject: [])
                        let error = EventsNearAddressUseCaseError.FetchingEventsError(underlyingError)
                        eventsNearAddressUseCase.simulateFailingToFindEvents(error)

                        expect(childControllerBuddy.lastOldSwappedController).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(childControllerBuddy.lastOldSwappedController) === interstitialController
                        expect(childControllerBuddy.lastNewSwappedController) === errorController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }
            }
        }
    }
}
