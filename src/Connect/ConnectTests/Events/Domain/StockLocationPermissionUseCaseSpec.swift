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
                        it("calls all granted callbacks (once, and only once)") {
                            var permissionGrantedHandlerCalledA = false

                            subject.askPermission({ () -> Void in
                                permissionGrantedHandlerCalledA = true
                                }, errorHandler: { (error) -> Void in
                                    fail("Denied handler called unexpectedly")
                            })

                            var permissionGrantedHandlerCalledB = false
                            subject.askPermission({ () -> Void in
                                permissionGrantedHandlerCalledB = true
                                }, errorHandler: { (error) -> Void in
                                    fail("Denied handler called unexpectedly")
                            })


                            locationManagerProxy.notifyObserversOfChangedAuthorizationStatus(.AuthorizedAlways)

                            expect(permissionGrantedHandlerCalledA) == true
                            expect(permissionGrantedHandlerCalledB) == true

                            permissionGrantedHandlerCalledA = false
                            permissionGrantedHandlerCalledB = false

                            locationManagerProxy.notifyObserversOfChangedAuthorizationStatus(.AuthorizedAlways)

                            expect(permissionGrantedHandlerCalledA) == false
                            expect(permissionGrantedHandlerCalledB) == false
                        }

                        it("notifies its observers that we got permission") {
                            locationManagerProxy.notifyObserversOfChangedAuthorizationStatus(.AuthorizedAlways)

                            expect(observerA.permissionGrantedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase
                            expect(observerB.permissionGrantedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase
                        }
                    }

                    describe("when the location manager proxy informs the use case that any other permission was granted") {
                        it("calls the denied handler") {
                            var deniedGrantedHandlerCalledA = false

                            subject.askPermission({ () -> Void in
                                fail("Granted handler called unexpectedly")
                                }, errorHandler: { (error) -> Void in
                                    deniedGrantedHandlerCalledA = true

                            })

                            locationManagerProxy.notifyObserversOfChangedAuthorizationStatus(.AuthorizedWhenInUse)

                            expect(deniedGrantedHandlerCalledA) == true

                            deniedGrantedHandlerCalledA = false

                            subject.askPermission({ () -> Void in
                                fail("Granted handler called unexpectedly")
                                }, errorHandler: { (error) -> Void in
                                    deniedGrantedHandlerCalledA = true

                            })

                            locationManagerProxy.notifyObserversOfChangedAuthorizationStatus(.Denied)

                            expect(deniedGrantedHandlerCalledA) == true


                            deniedGrantedHandlerCalledA = false

                            subject.askPermission({ () -> Void in
                                fail("Granted handler called unexpectedly")
                                }, errorHandler: { (error) -> Void in
                                    deniedGrantedHandlerCalledA = true

                            })

                            locationManagerProxy.notifyObserversOfChangedAuthorizationStatus(.NotDetermined)

                            expect(deniedGrantedHandlerCalledA) == true


                            deniedGrantedHandlerCalledA = false

                            subject.askPermission({ () -> Void in
                                fail("Granted handler called unexpectedly")
                                }, errorHandler: { (error) -> Void in
                                    deniedGrantedHandlerCalledA = true

                            })

                            locationManagerProxy.notifyObserversOfChangedAuthorizationStatus(.Restricted)

                            expect(deniedGrantedHandlerCalledA) == true
                        }

                        it("calls the denied handlers once, and only once") {
                            var deniedGrantedHandlerCalledA = false

                            subject.askPermission({ () -> Void in
                                fail("Granted handler called unexpectedly")
                                }, errorHandler: { (error) -> Void in
                                    deniedGrantedHandlerCalledA = true

                            })

                            var deniedGrantedHandlerCalledB = false

                            subject.askPermission({ () -> Void in
                                fail("Granted handler called unexpectedly")
                                }, errorHandler: { (error) -> Void in
                                    deniedGrantedHandlerCalledB = true

                            })

                            locationManagerProxy.notifyObserversOfChangedAuthorizationStatus(.Restricted)

                            expect(deniedGrantedHandlerCalledA) == true
                            expect(deniedGrantedHandlerCalledB) == true

                            deniedGrantedHandlerCalledA = false
                            deniedGrantedHandlerCalledB = false

                            locationManagerProxy.notifyObserversOfChangedAuthorizationStatus(.Restricted)

                            expect(deniedGrantedHandlerCalledA) == false
                            expect(deniedGrantedHandlerCalledB) == false
                        }

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
                    it("calls the denied handler") {
                        locationManagerProxy.returnedAuthorizationStatus = .Denied

                        var deniedGrantedHandlerCalled = false

                        subject.askPermission({ () -> Void in
                            fail("Granted handler called unexpectedly")
                            }, errorHandler: { (error) -> Void in
                                deniedGrantedHandlerCalled = true

                        })

                        expect(deniedGrantedHandlerCalled) == true
                    }

                    it("immediately notifies observers that permission was denied") {
                        locationManagerProxy.returnedAuthorizationStatus = .Denied

                        subject.askPermission()

                        expect(observerA.permissionRejectedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase
                        expect(observerB.permissionRejectedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase
                    }
                }

                context("when permission has been restricted") {
                    it("calls the denied handler") {
                        locationManagerProxy.returnedAuthorizationStatus = .Restricted

                        var deniedGrantedHandlerCalled = false

                        subject.askPermission({ () -> Void in
                            fail("Granted handler called unexpectedly")
                            }, errorHandler: { (error) -> Void in
                                deniedGrantedHandlerCalled = true

                        })

                        expect(deniedGrantedHandlerCalled) == true
                    }

                    it("immediately notifies observers that permission was denied") {
                        locationManagerProxy.returnedAuthorizationStatus = .Restricted

                        subject.askPermission()

                        expect(observerA.permissionRejectedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase
                        expect(observerB.permissionRejectedForUseCase as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase
                    }
                }

                context("when permission has previously been granted as always") {
                    it("calls the granted callback") {
                        locationManagerProxy.returnedAuthorizationStatus = .AuthorizedAlways

                        var permissionGrantedHandlerCalled = false

                        subject.askPermission({ () -> Void in
                            permissionGrantedHandlerCalled = true
                            }, errorHandler: { (error) -> Void in
                                fail("Denied handler called unexpectedly")
                        })

                        expect(permissionGrantedHandlerCalled) == true
                    }

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


