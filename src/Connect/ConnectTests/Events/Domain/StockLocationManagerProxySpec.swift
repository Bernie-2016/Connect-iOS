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
                    subject.requestWhenInUseAuthorization()

                    expect(locationManager.didRequestAlwaysAuthorization) == true
                }
            }

            describe("when the location manager changes authorization status") {
                it("notifies its observers") {
                    locationManager.delegate?.locationManager!(locationManager, didChangeAuthorizationStatus: .AuthorizedWhenInUse)

                    expect(observerA.lastUpdatedStatusProxy as? StockLocationManagerProxy) === subject as? StockLocationManagerProxy
                    expect(observerA.lastUpdatedStatus) == .AuthorizedWhenInUse

                    expect(observerB.lastUpdatedStatusProxy as? StockLocationManagerProxy) === subject as? StockLocationManagerProxy
                    expect(observerB.lastUpdatedStatus) == .AuthorizedWhenInUse
                }
            }

            describe("when the location manager updates locations") {
                it("notifies its observers") {
                    let locationA = CLLocation(latitude: 1, longitude: 2)
                    let locationB = CLLocation(latitude: 3, longitude: 4)
                    let expectedLocations = [locationA, locationB]
                    locationManager.delegate?.locationManager!(locationManager, didUpdateLocations: expectedLocations)

                    expect(observerA.lastUpdatedLocationProxy as? StockLocationManagerProxy) === subject as? StockLocationManagerProxy
                    expect(observerA.lastUpdatedLocationLocations) == expectedLocations

                    expect(observerB.lastUpdatedLocationProxy as? StockLocationManagerProxy) === subject as? StockLocationManagerProxy
                    expect(observerB.lastUpdatedLocationLocations) == expectedLocations
                }
            }

            describe("when the location manager fails to update locations") {
                it("notifies its observers") {
                    let expectedError = NSError(domain: "bad", code: 42, userInfo: nil)
                    locationManager.delegate?.locationManager!(locationManager, didFailWithError: expectedError)

                    expect(observerA.lastErroredProxy as? StockLocationManagerProxy) === subject as? StockLocationManagerProxy
                    expect(observerA.lastError) == expectedError

                    expect(observerB.lastErroredProxy as? StockLocationManagerProxy) === subject as? StockLocationManagerProxy
                    expect(observerB.lastError) == expectedError
                }
            }

            describe("requesting the current location") {
                it("proxies through to the correct method on the location manager") {
                    subject.startUpdatingLocations()

                    expect(locationManager.didStartUpdatingLocations) == true
                }
            }
        }
    }
}

private class MockLocationManager: CLLocationManager {
    var didRequestAlwaysAuthorization = false
    private override func requestWhenInUseAuthorization() {
        didRequestAlwaysAuthorization = true
    }

    var didRequestLocation = false
    private override func requestLocation() {
        didRequestLocation = true
    }

    var didStartUpdatingLocations = false
    private override func startUpdatingLocation() {
        didStartUpdatingLocations = true
    }
}

private class MockLocationManagerProxyObserver: LocationManagerProxyObserver {
    private var lastUpdatedStatusProxy: LocationManagerProxy?
    private var lastUpdatedStatus: CLAuthorizationStatus?

    private func locationManagerProxy(locationManagerProxy: LocationManagerProxy, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        lastUpdatedStatusProxy = locationManagerProxy
        lastUpdatedStatus = status
    }

    private var lastUpdatedLocationProxy: LocationManagerProxy?
    private var lastUpdatedLocationLocations: [CLLocation]?
    private func locationManagerProxy(locationManagerProxy: LocationManagerProxy, didUpdateLocations locations: [CLLocation]) {
        lastUpdatedLocationProxy = locationManagerProxy
        lastUpdatedLocationLocations = locations
    }

    private var lastErroredProxy: LocationManagerProxy?
    private var lastError: NSError?
    private func locationManagerProxy(locationManagerProxy: LocationManagerProxy, didFailWithError error: NSError) {
            lastErroredProxy = locationManagerProxy
            lastError = error
    }
}
