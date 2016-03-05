import Quick
import Nimble
import CoreLocation

@testable import Connect

class StockLocationManagerProxySpec: QuickSpec {
    override func spec() {
        describe("StockLocationManagerProxy") {
            var subject: LocationManagerProxy!
            var locationManager: MockLocationManager!

            var observerA: MockLocationManagerProxyObserver!
            var observerB: MockLocationManagerProxyObserver!

            beforeEach {
                locationManager = MockLocationManager()

                subject = StockLocationManagerProxy(
                    locationManager: locationManager
                )

                observerA = MockLocationManagerProxyObserver()
                observerB = MockLocationManagerProxyObserver()

                subject.addObserver(observerA)
                subject.addObserver(observerB)
            }

            it("sets itself as the delegate of the location manager") {
                expect(locationManager.delegate) === subject as? CLLocationManagerDelegate
            }

            describe("requesting always authorization") {
                it("proxies to the location manager") {
                    subject.requestAlwaysAuthorization()

                    expect(locationManager.didRequestAlwaysAuthorization) == true
                }
            }

            describe("when the location manager changes authorization status") {
                it("notifies its observers") {
                    locationManager.delegate?.locationManager!(locationManager, didChangeAuthorizationStatus: .AuthorizedAlways)

                    expect(observerA.lastUpdatedStatusProxy as? StockLocationManagerProxy) === subject as? StockLocationManagerProxy
                    expect(observerA.lastUpdatedStatus) == .AuthorizedAlways

                    expect(observerB.lastUpdatedStatusProxy as? StockLocationManagerProxy) === subject as? StockLocationManagerProxy
                    expect(observerB.lastUpdatedStatus) == .AuthorizedAlways
                }
            }
        }
    }
}

private class MockLocationManager: CLLocationManager {
    var didRequestAlwaysAuthorization = false
    private override func requestAlwaysAuthorization() {
        didRequestAlwaysAuthorization = true
    }
}

private class MockLocationManagerProxyObserver: LocationManagerProxyObserver {
    private var lastUpdatedStatusProxy: LocationManagerProxy?
    private var lastUpdatedStatus: CLAuthorizationStatus?

    private func locationManagerProxy(locationManagerProxy: LocationManagerProxy, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        lastUpdatedStatusProxy = locationManagerProxy
        lastUpdatedStatus = status
    }
}
