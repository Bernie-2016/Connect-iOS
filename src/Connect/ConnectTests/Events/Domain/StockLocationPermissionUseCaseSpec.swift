import Quick
import Nimble
import CoreLocation

@testable import Connect

class StockLocationPermissionUseCaseSpec: QuickSpec {
    override func spec() {
        describe("StockLocationPermissionUseCase") {
            var subject: LocationPermissionUseCase!
            var locationManagerProxy: MockLocationManagerProxy!

            beforeEach {
                locationManagerProxy = MockLocationManagerProxy()

                subject = StockLocationPermissionUseCase(
                    locationManagerProxy: locationManagerProxy
                )
            }

            it("adds itself as an observer of the location manager proxy") {
                expect(locationManagerProxy.observers.count) == 1
                expect(locationManagerProxy.observers.first as? StockLocationPermissionUseCase) === subject as? StockLocationPermissionUseCase
            }

            describe("asking for permission") {
                it("asks the proxy for permission") {
                    subject.askPermission({ () -> Void in

                        }, errorHandler: { () -> Void in

                    })

                    expect(locationManagerProxy.didRequestInUseAuthorization) == true
                }

                context("when permission is not determined") {
                    describe("when the location manager proxy informs the use case that in use permission was granted") {
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


                            locationManagerProxy.notifyObserversOfChangedAuthorizationStatus(.AuthorizedWhenInUse)

                            expect(permissionGrantedHandlerCalledA) == true
                            expect(permissionGrantedHandlerCalledB) == true

                            permissionGrantedHandlerCalledA = false
                            permissionGrantedHandlerCalledB = false

                            locationManagerProxy.notifyObserversOfChangedAuthorizationStatus(.AuthorizedWhenInUse)

                            expect(permissionGrantedHandlerCalledA) == false
                            expect(permissionGrantedHandlerCalledB) == false
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

                            locationManagerProxy.notifyObserversOfChangedAuthorizationStatus(.AuthorizedAlways)

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
                }

                context("when permission has previously been granted") {
                    it("calls the granted callback") {
                        locationManagerProxy.returnedAuthorizationStatus = .AuthorizedWhenInUse

                        var permissionGrantedHandlerCalled = false

                        subject.askPermission({ () -> Void in
                            permissionGrantedHandlerCalled = true
                            }, errorHandler: { (error) -> Void in
                                fail("Denied handler called unexpectedly")
                        })

                        expect(permissionGrantedHandlerCalled) == true
                    }
                }
            }
        }
    }
}



