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
            var fetchEventsUseCase: MockFetchEventsUseCase!
            var childControllerBuddy: MockChildControllerBuddy!

            beforeEach {
                interstitialController = UIViewController()
                instructionsController = UIViewController()
                errorController = UIViewController()
                fetchEventsUseCase = MockFetchEventsUseCase()
                childControllerBuddy = MockChildControllerBuddy()

                subject = NewEventsController(
                    interstitialController: interstitialController,
                    instructionsController: instructionsController,
                    errorController: errorController,
                    fetchEventsUseCase: fetchEventsUseCase,
                    childControllerBuddy: childControllerBuddy
                )
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
        }
    }
}

//private class MockCurrentLocationUseCase: CurrentLocationUseCase {
//    var observers = [CurrentLocationUseCaseObserver]()
//
//    private func addObserver(observer: CurrentLocationUseCaseObserver) {
//        observers.append(observer)
//    }
//
//
//    var successHandlers: [(CLLocation) -> ()] = []
//    var errorHandlers: [(CurrentLocationUseCaseError) -> ()] = []
//    var didFetchCurrentLocation = false
//    private func fetchCurrentLocation(successHandler: (CLLocation) -> (), errorHandler: (CurrentLocationUseCaseError) -> ()) {
//        didFetchCurrentLocation = true
//        successHandler.append(successHandler)
//        errorHandlers.append(errorHandlers)
//    }
//
//    private func simulateFoundLocation(location: CLLocation) {
//        for handler in successHandlers {
//            handler(location)
//        }
//        handlers.removeAll()
//    }
//
//    private func simulateFailure() {
//        for handler in errorHandlers {
//            handler(.PermissionsError)
//        }
//        handlers.removeAll()
//    }
//}

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
