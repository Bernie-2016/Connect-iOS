import Quick
import Nimble
import CoreLocation

@testable import Connect

class StockLocationPermissionUseCaseSpec: QuickSpec {
    override func spec() {
        describe("StockLocationPermissionUseCase") {
            var subject: LocationPermissionUseCase!
            var locationManagerProxy: MockLocationManagerProxy!

            var observerA: MockLocationPermissionUseCaseObserver!
            var observerB: MockLocationPermissionUseCaseObserver!

            beforeEach {
                locationManagerProxy = MockLocationManagerProxy()

                subject = StockLocationPermissionUseCase(
                    locationManagerProxy: locationManagerProxy
                )

                observerA = MockLocationPermissionUseCaseObserver()
                observerB = MockLocationPermissionUseCaseObserver()

                subject.addObserver(observerA)
                subject.addObserver(observerB)
            }

            it("adds itself as an observer of the location manager proxy") {
                expect(locationManagerProxy.observers.count) == 1
                expect(locationManagerProxy.observers.first as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase
            }

            describe("asking for permission") {
                context("when permission is not determined") {
                    it("asks the location manager for always permission") {
                        locationManagerProxy.returnedAuthorizationStatus = .NotDetermined

                        subject.askPermission()

                        expect(locationManagerProxy.didRequestAlwaysAuthorized) == true
                    }

                    describe("when the location manager proxy informs the use case that always permission was granted") {
                        it("notifies its observers that we got permission") {
                            locationManagerProxy.notifyObserversOfChangedAuthorizationStatus(.AuthorizedAlways)

                            expect(observerA.permissionGrantedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase
                            expect(observerB.permissionGrantedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase
                        }
                    }

                    describe("when the location manager proxy informs the use case that any other permission was granted") {
                        it("notifies its observers that we were denied permission") {
                            locationManagerProxy.notifyObserversOfChangedAuthorizationStatus(.AuthorizedWhenInUse)

                            expect(observerA.permissionRejectedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase
                            expect(observerB.permissionRejectedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase

                            observerA.reset()
                            observerB.reset()

                            locationManagerProxy.notifyObserversOfChangedAuthorizationStatus(.Denied)

                            expect(observerA.permissionRejectedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase
                            expect(observerB.permissionRejectedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase

                            observerA.reset()
                            observerB.reset()

                            locationManagerProxy.notifyObserversOfChangedAuthorizationStatus(.NotDetermined)

                            expect(observerA.permissionRejectedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase
                            expect(observerB.permissionRejectedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase

                            observerA.reset()
                            observerB.reset()

                            locationManagerProxy.notifyObserversOfChangedAuthorizationStatus(.Restricted)

                            expect(observerA.permissionRejectedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase
                            expect(observerB.permissionRejectedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase

                            observerA.reset()
                            observerB.reset()
                        }
                    }
                }

                context("when permission has previously been denied") {
                    it("immediately notifies observers that permission was denied") {
                        locationManagerProxy.returnedAuthorizationStatus = .Denied

                        subject.askPermission()

                        expect(observerA.permissionRejectedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase
                        expect(observerB.permissionRejectedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase
                    }
                }

                context("when permission has been restricted") {
                    it("immediately notifies observers that permission was denied") {
                        locationManagerProxy.returnedAuthorizationStatus = .Restricted

                        subject.askPermission()

                        expect(observerA.permissionRejectedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase
                        expect(observerB.permissionRejectedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase
                    }
                }

                context("when permission has previously been granted as always") {
                    it("immediately notifies observers that permission was granted") {
                        locationManagerProxy.returnedAuthorizationStatus = .AuthorizedAlways

                        subject.askPermission()

                        expect(observerA.permissionGrantedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase
                        expect(observerB.permissionGrantedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase

                        expect(observerA.permissionRejectedForUseCase).to(beNil())
                        expect(observerB.permissionRejectedForUseCase).to(beNil())
                    }
                }
            }
        }
    }
}

private class MockLocationPermissionUseCaseObserver: LocationPermissionUseCaseObserver {
    func reset() {
        permissionGrantedForUseCase = nil
        permissionRejectedForUseCase = nil
    }

    var permissionRejectedForUseCase: LocationPermissionUseCase?
    private func locationPermissionUseCaseDidDenyPermission(useCase: LocationPermissionUseCase) {
        permissionRejectedForUseCase = useCase
    }


    var permissionGrantedForUseCase: LocationPermissionUseCase?
    private func locationPermissionUseCaseDidGrantPermission(useCase: LocationPermissionUseCase) {
        permissionGrantedForUseCase = useCase
    }
}

private class MockLocationManagerProxy: LocationManagerProxy {
    var returnedAuthorizationStatus: CLAuthorizationStatus?

    var observers = [LocationManagerProxyObserver]()
    private func addObserver(observer: LocationManagerProxyObserver) {
        observers.append(observer)
    }

    private func authorizationStatus() -> CLAuthorizationStatus {
        return returnedAuthorizationStatus!
    }

    var didRequestAlwaysAuthorized = false
    private func requestAlwaysAuthorization() {
        didRequestAlwaysAuthorized = true
    }

    func notifyObserversOfChangedAuthorizationStatus(status: CLAuthorizationStatus) {
        for observer in observers {
            observer.locationManagerProxy(self, didChangeAuthorizationStatus: status)
        }
    }
}


