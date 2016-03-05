import Quick
import Nimble
import CoreLocation

@testable import Connect

class NewEventsControllerSpec: QuickSpec {
    override func spec() {
        describe("NewEventsController") {
            var subject: NewEventsController!
            var interstitialController: UIViewController!
            var instructionsController: UIViewController!
            var errorController: UIViewController!
            var locationPermissionUseCase: MockLocationPermissionUseCase!
            var currentLocationUseCase: MockCurrentLocationUseCase!
            var fetchEventsUseCase: MockFetchEventsUseCase!
            var childControllerBuddy: MockChildControllerBuddy!

            beforeEach {
                interstitialController = UIViewController()
                instructionsController = UIViewController()
                errorController = UIViewController()
                locationPermissionUseCase = MockLocationPermissionUseCase()
                currentLocationUseCase = MockCurrentLocationUseCase()
                fetchEventsUseCase = MockFetchEventsUseCase()
                childControllerBuddy = MockChildControllerBuddy()

                subject = NewEventsController(
                    interstitialController: interstitialController,
                    instructionsController: instructionsController,
                    errorController: errorController,
                    locationPermissionUseCase: locationPermissionUseCase,
                    currentLocationUseCase: currentLocationUseCase,
                    fetchEventsUseCase: fetchEventsUseCase,
                    childControllerBuddy: childControllerBuddy
                )
            }

            it("adds itself as an observer of the location permission use case") {
                expect(locationPermissionUseCase.observers.count) == 1
                expect(locationPermissionUseCase.observers.first as? NewEventsController) === subject
            }

            it("adds itself as an observer of the fetch location use case") {
                expect(currentLocationUseCase.observers.count) == 1
                expect(currentLocationUseCase.observers.first as? NewEventsController) === subject
            }

            describe("when the view loads") {
                it("adds the results view as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.resultsView))
                }

                it("initially adds the interstitial controller as a child controller in the results view") {
                    subject.view.layoutSubviews()

                    expect(childControllerBuddy.lastAddedViewController) === interstitialController
                    expect(childControllerBuddy.lastAddedParentViewController) === subject
                    expect(childControllerBuddy.lastAddedContainerView) === subject.resultsView
                }
            }

            describe("as a location permission use case observer") {
                describe("when the location permission use case reports that permission was granted") {
                    it("asks the current location use case for the current location") {
                        locationPermissionUseCase.grantPermission()

                        expect(currentLocationUseCase.didFetchCurrentLocation) == true
                    }
                }

                describe("when the location permission use case reports that permission was denied") {
                    beforeEach {
                        subject.view.layoutSubviews()
                    }

                    it("does not try to fetch the location") {
                        locationPermissionUseCase.denyPermission()

                        expect(currentLocationUseCase.didFetchCurrentLocation) == false
                    }

                    it("swaps in the instructions controller into the results view") {
                        locationPermissionUseCase.denyPermission()

                        expect(childControllerBuddy.lastOldSwappedController) === interstitialController
                        expect(childControllerBuddy.lastNewSwappedController) === instructionsController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }
            }

            describe("as a current location use case observer") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                describe("when the location use case notifies its observers of the current location") {
                    it("asks the find events use case to fetch events around the given location, within a 10 mile radius") {
                        let expectedLocation = CLLocation(latitude: 1, longitude: 2)
                        currentLocationUseCase.simulateFoundLocation(expectedLocation)

                        expect(fetchEventsUseCase.lastFetchedLocation) == expectedLocation
                        expect(fetchEventsUseCase.lastFetchedRadiusMiles) == 10
                    }
                }

                describe("when the location use case notifies its observers of failure to obtain the current location") {
                    it("shows the error controller in the results view") {
                        currentLocationUseCase.simulateFailure()

                        expect(childControllerBuddy.lastOldSwappedController) === interstitialController
                        expect(childControllerBuddy.lastNewSwappedController) === errorController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }
            }
        }
    }
}

private class MockCurrentLocationUseCase: CurrentLocationUseCase {
    var observers = [CurrentLocationUseCaseObserver]()

    private func addObserver(observer: CurrentLocationUseCaseObserver) {
        observers.append(observer)
    }

    var didFetchCurrentLocation = false
    private func fetchCurrentLocation() {
        didFetchCurrentLocation = true
    }

    private func simulateFoundLocation(location: CLLocation) {
        for observer in observers {
            observer.currentLocationUseCase(self, didFetchCurrentLocation: location)
        }
    }

    private func simulateFailure() {
        for observer in observers {
            observer.currentLocationUseCaseFailedToFetchLocation()
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

private class MockFetchEventsUseCase: FetchEventsUseCase {
    var lastFetchedLocation: CLLocation?
    var lastFetchedRadiusMiles: Float?
    private func fetchEventsAroundLocation(location: CLLocation, radiusMiles: Float) {
        lastFetchedLocation = location
        lastFetchedRadiusMiles = radiusMiles
    }
}
