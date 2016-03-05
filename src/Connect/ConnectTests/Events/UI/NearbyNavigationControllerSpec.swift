import Quick
import Nimble

@testable import Connect

class NearbyNavigationControllerSpec: QuickSpec {
    override func spec() {
        describe("NearbyNavigationController") {
            var subject: NearbyNavigationController!
            var interstitialController: UIViewController!
            var locationPermissionUseCase: MockLocationPermissionUseCase!
            var eventsController: UIViewController!

            beforeEach {
                interstitialController = UIViewController()
                eventsController = UIViewController()
                locationPermissionUseCase = MockLocationPermissionUseCase()

                subject = NearbyNavigationController(
                    interstitialController: interstitialController,
                    eventsController: eventsController,
                    locationPermissionUseCase: locationPermissionUseCase
                )
            }

            describe("when the view first loads") {
                it("shows the interstitial controller") {
                    subject.view.layoutSubviews()

                    expect(subject.topViewController) === interstitialController
                }

                it("asks the LocationPermissionUseCase for permission for the current location") {
                    subject.view.layoutSubviews()

                    expect(locationPermissionUseCase.hasBeenAskedForPermission) == true
                }
            }

            describe("as a LocationPermissionUseCaseObserver") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                describe("when permission is granted") {
                    it("swaps the interstitial controller for the events controller") {
                        subject.locationPermissionUseCaseDidGrantPermission(locationPermissionUseCase)

                        expect(subject.topViewController) === eventsController
                        expect(subject.viewControllers.count) == 1
                    }
                }

                describe("when permission is rejected") {
                    it("swaps the interstitial controller for the events controller") {
                        subject.locationPermissionUseCaseDidRejectPermission(locationPermissionUseCase)

                        expect(subject.topViewController) === eventsController
                        expect(subject.viewControllers.count) == 1
                    }
                }
            }
        }
    }
}

private class MockLocationPermissionUseCase: LocationPermissionUseCase {
    var hasBeenAskedForPermission = false

    private func askPermission() {
        hasBeenAskedForPermission = true
    }
}

