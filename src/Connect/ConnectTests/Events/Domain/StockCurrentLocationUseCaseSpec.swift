import Quick
import Nimble
import CoreLocation

@testable import Connect

class StockCurrentLocationUseCaseSpec: QuickSpec {
    override func spec() {
        describe("StockCurrentLocationUseCase") {
            var subject: CurrentLocationUseCase!
            var locationManagerProxy: MockLocationManagerProxy!
            var locationPermissionUseCase: MockLocationPermissionUseCase!

            beforeEach {
                locationManagerProxy = MockLocationManagerProxy()
                locationPermissionUseCase = MockLocationPermissionUseCase()

                subject = StockCurrentLocationUseCase(
                    locationManagerProxy: locationManagerProxy,
                    locationPermissionUseCase: locationPermissionUseCase
                )
            }

            it("adds itself as an observer of the location manager proxy") {
                expect(locationManagerProxy.observers.count) == 1
                expect(locationManagerProxy.observers.first as? StockCurrentLocationUseCase) === subject as? StockCurrentLocationUseCase
            }

            describe("getting the current location") {
                it("asks the location permission use case for permission") {
                    subject.fetchCurrentLocation({ (location) -> () in

                        }, errorHandler: { (error) -> () in

                    })

                    expect(locationPermissionUseCase.hasBeenAskedForPermission) == true
                }

                context("when permission is granted") {
                    it("tells the location manager proxy to start updating locations") {
                        subject.fetchCurrentLocation({ (location) -> () in

                            }, errorHandler: { (error) -> () in

                        })

                        locationPermissionUseCase.grantPermission()

                        expect(locationManagerProxy.didStartUpdatingLocations) == true

                    }

                    describe("when the current location proxy hasn't yet given us a location") {
                        context("and then a location is reported") {
                            it("waits until a location is available to call the completion handler, once and only once") {
                                var receivedLocationA: CLLocation?
                                subject.fetchCurrentLocation({ (location) -> () in
                                    receivedLocationA = location
                                    }, errorHandler: { (error) -> () in
                                        fail("Should not have called error handler")
                                })

                                var receivedLocationB: CLLocation?
                                subject.fetchCurrentLocation({ (location) -> () in
                                    receivedLocationB = location
                                    }, errorHandler: { (error) -> () in
                                        fail("Should not have called error handler")
                                })

                                locationPermissionUseCase.grantPermission()

                                expect(receivedLocationA).to(beNil())
                                expect(receivedLocationB).to(beNil())

                                let otherLocation = CLLocation(latitude: 1, longitude: 2)
                                let expectedLocation = CLLocation(latitude: 3, longitude: 4)
                                locationManagerProxy.notifyObserversOfNewLocations([otherLocation, expectedLocation])

                                expect(receivedLocationA) === expectedLocation
                                expect(receivedLocationB) === expectedLocation

                                receivedLocationA = nil
                                receivedLocationB = nil

                                locationManagerProxy.notifyObserversOfNewLocations([otherLocation, expectedLocation])

                                expect(receivedLocationA).to(beNil())
                                expect(receivedLocationB).to(beNil())
                            }
                        }

                        context("and then an error is reported") {
                            it("waits until that error is reported begore calling the completion handler, once and only once") {
                                var receivedErrorA: CurrentLocationUseCaseError?
                                subject.fetchCurrentLocation({ (location) -> () in
                                    fail("Should not have called success handler")
                                    }, errorHandler: { (error) -> () in
                                        receivedErrorA = error
                                })

                                var receivedErrorB: CurrentLocationUseCaseError?
                                subject.fetchCurrentLocation({ (location) -> () in
                                    fail("Should not have called success handler")
                                    }, errorHandler: { (error) -> () in
                                    receivedErrorB = error
                                })

                                locationPermissionUseCase.grantPermission()

                                expect(receivedErrorA).to(beNil())
                                expect(receivedErrorB).to(beNil())

                                let underlyingError = NSError(domain: "wat", code: 42, userInfo: nil)
                                locationManagerProxy.notifyObserversOfError(underlyingError)

                                expect(receivedErrorA) == CurrentLocationUseCaseError.CoreLocationError(underlyingError)
                                expect(receivedErrorB) == CurrentLocationUseCaseError.CoreLocationError(underlyingError)

                                receivedErrorA = nil
                                receivedErrorB = nil

                                locationManagerProxy.notifyObserversOfError(underlyingError)

                                expect(receivedErrorA).to(beNil())
                                expect(receivedErrorB).to(beNil())
                            }
                        }
                    }

                    describe("when the current loaction proxy has already reported a location") {
                        it("calls the completion handler immediately with that location") {
                            subject.fetchCurrentLocation({ (location) -> () in

                                }, errorHandler: { (error) -> () in

                            })

                            locationPermissionUseCase.grantPermission()
                            let expectedLocation = CLLocation(latitude: 3, longitude: 4)
                            locationManagerProxy.notifyObserversOfNewLocations([expectedLocation])

                            var receivedLocation: CLLocation?
                            subject.fetchCurrentLocation({ (location) -> () in
                                receivedLocation = location
                                }, errorHandler: { (error) -> () in
                                    fail("Should not have called error handler")
                            })


                            expect(receivedLocation) === expectedLocation
                        }

                        it("does not buffer error handlers") {
                            subject.fetchCurrentLocation({ (location) -> () in
                                }, errorHandler: { (error) -> () in
                                    fail("Should not have called error handler")
                            })

                            locationPermissionUseCase.grantPermission()
                            locationManagerProxy.notifyObserversOfNewLocations([CLLocation(latitude: 3, longitude: 4)])
                            let underlyingError = NSError(domain: "wat", code: 42, userInfo: nil)
                            locationManagerProxy.notifyObserversOfError(underlyingError)
                        }
                    }

                    describe("when the current location proxy has most recently reported an error") {
                        it("calls the error handler immediately") {
                            subject.fetchCurrentLocation({ (location) -> () in

                                }, errorHandler: { (error) -> () in

                            })

                            locationPermissionUseCase.grantPermission()
                            locationManagerProxy.notifyObserversOfNewLocations([CLLocation(latitude: 3, longitude: 4)])
                            let underlyingError = NSError(domain: "wat", code: 42, userInfo: nil)
                            locationManagerProxy.notifyObserversOfError(underlyingError)


                            var receivedError: CurrentLocationUseCaseError?
                            subject.fetchCurrentLocation({ (location) -> () in
                                fail("Should not have called success handler")
                                }, errorHandler: { (error) -> () in
                                    receivedError = error
                            })


                            expect(receivedError) == CurrentLocationUseCaseError.CoreLocationError(underlyingError)
                        }

                        it("does not buffer completion handlers") {
                            subject.fetchCurrentLocation({ (location) -> () in
                                fail("Should not have called completion handler")
                                }, errorHandler: { (error) -> () in

                            })

                            locationPermissionUseCase.grantPermission()
                            let underlyingError = NSError(domain: "wat", code: 42, userInfo: nil)
                            locationManagerProxy.notifyObserversOfError(underlyingError)
                            locationManagerProxy.notifyObserversOfNewLocations([CLLocation(latitude: 3, longitude: 4)])
                        }
                    }
                }

                context("when permission is denied") {
                    it("calls the error handlers, once and only once") {
                        var didCallErrorHandlerWithErrorA: CurrentLocationUseCaseError?
                        subject.fetchCurrentLocation({ (location) -> () in
                                fail("Current location handler erroneously called")
                            }, errorHandler: { (error) -> () in
                                didCallErrorHandlerWithErrorA = error
                        })

                        var didCallErrorHandlerWithErrorB: CurrentLocationUseCaseError?
                        subject.fetchCurrentLocation({ (location) -> () in
                            fail("Current location handler erroneously called")
                            }, errorHandler: { (error) -> () in
                                didCallErrorHandlerWithErrorB = error
                        })

                        locationPermissionUseCase.denyPermission()

                        expect(didCallErrorHandlerWithErrorA) == .PermissionsError
                        expect(didCallErrorHandlerWithErrorB) == .PermissionsError
                    }
                }
            }
        }
    }
}
