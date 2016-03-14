import Quick
import Nimble
import CoreLocation
import MapKit

@testable import Connect

class StockEventsNearAddressUseCaseSpec: QuickSpec {
    override func spec() {
        describe("StockEventsNearAddressUseCase") {
            var subject: EventsNearAddressUseCase!
            var geocoder: FakeGeocoder!
            var eventRepository: MockEventRepository!

            var observerA: MockEventsNearAddressUseCaseObserver!
            var observerB: MockEventsNearAddressUseCaseObserver!

            beforeEach {
                geocoder = FakeGeocoder()
                eventRepository = MockEventRepository()

                subject = StockEventsNearAddressUseCase(
                    geocoder: geocoder,
                    eventRepository: eventRepository
                )

                observerA = MockEventsNearAddressUseCaseObserver()
                observerB = MockEventsNearAddressUseCaseObserver()

                subject.addObserver(observerA)
                subject.addObserver(observerB)
            }

            describe("fetching events near an address") {
                it("notifies the observers that it has started fetching events") {
                    subject.fetchEventsNearAddress("cool town", radiusMiles: 10.0)

                    expect(observerA.didStartFetchingEventsWithUseCase) === subject as? StockEventsNearAddressUseCase
                    expect(observerB.didStartFetchingEventsWithUseCase) === subject as? StockEventsNearAddressUseCase
                }

                it("asks the geocoder to geocode the address string") {
                    subject.fetchEventsNearAddress("cool town", radiusMiles: 10.0)

                    expect(geocoder.lastReceivedAddressString).to(equal("cool town"))
                }

                describe("when geocoding succeeds") {
                    beforeEach {
                        subject.fetchEventsNearAddress("cool town", radiusMiles: 10.0)
                    }

                    it("asks the event repository to find events around the first location, with the given radius") {
                        let coordinate = CLLocationCoordinate2DMake(12.34, 23.45)
                        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)

                        let otherCoordinate = CLLocationCoordinate2DMake(11.11, 11.11)
                        let otherPlacemark = MKPlacemark(coordinate: otherCoordinate, addressDictionary: nil)

                        geocoder.lastReceivedCompletionHandler([placemark, otherPlacemark], nil)

                        expect(eventRepository.didFetchEventsAroundLocation?.coordinate.latitude) == 12.34
                        expect(eventRepository.didFetchEventsAroundLocation?.coordinate.longitude) == 23.45
                        expect(eventRepository.didFetchEventsWithRadiusMiles = 10.0)
                    }

                    describe("when the event repository resolves its promise with some results") {
                        beforeEach {
                            let coordinate = CLLocationCoordinate2DMake(12.34, 23.45)
                            let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)

                            geocoder.lastReceivedCompletionHandler([placemark], nil)
                        }

                        context("and there is more than zero results") {
                            it("notifies its observers with those events") {
                                let eventA = TestUtils.eventWithName("A")
                                let eventB = TestUtils.eventWithName("B")
                                let expectedSearchResult = EventSearchResult(events: [eventA, eventB])

                                eventRepository.lastReturnedPromise!.resolve(expectedSearchResult)

                                expect(observerA.didFindEventsWithUseCase) === subject as? StockEventsNearAddressUseCase
                                expect(observerA.didFindEvents) === expectedSearchResult

                                expect(observerB.didFindEventsWithUseCase) === subject as? StockEventsNearAddressUseCase
                                expect(observerB.didFindEvents) === expectedSearchResult
                            }
                        }

                        context("and there are zero results") {
                            it("notifies its observers") {
                                let searchResult = EventSearchResult(events: [])

                                eventRepository.lastReturnedPromise!.resolve(searchResult)

                                expect(observerA.didFindNoEventsWithUseCase) === subject as? StockEventsNearAddressUseCase
                                expect(observerB.didFindNoEventsWithUseCase) === subject as? StockEventsNearAddressUseCase
                            }
                        }
                    }

                    describe("when the event repository encounters an error") {
                        beforeEach {
                            let coordinate = CLLocationCoordinate2DMake(12.34, 23.45)
                            let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)

                            geocoder.lastReceivedCompletionHandler([placemark], nil)
                        }

                        it("notifies its observers of the error") {
                            let underlyingError = EventRepositoryError.InvalidJSONError(jsonObject: [])

                            eventRepository.lastReturnedPromise.reject(underlyingError)

                            expect(observerA.didFailWithUseCase) === subject as? StockEventsNearAddressUseCase
                            expect(observerA.didFailWithError) == EventsNearAddressUseCaseError.FetchingEventsError(underlyingError)

                            expect(observerB.didFailWithUseCase) === subject as? StockEventsNearAddressUseCase
                            expect(observerB.didFailWithError) == EventsNearAddressUseCaseError.FetchingEventsError(underlyingError)
                        }
                    }
                }

                describe("when geocoding fails") {
                    beforeEach {
                        subject.fetchEventsNearAddress("cool town", radiusMiles: 10.0)
                    }

                    it("notifies observers of geocoding failure") {
                        let underlyingError = NSError(domain: "", code: 42, userInfo: nil)
                        geocoder.lastReceivedCompletionHandler(nil, underlyingError)

                        expect(observerA.didFailWithUseCase) === subject as? StockEventsNearAddressUseCase
                        expect(observerA.didFailWithError) == EventsNearAddressUseCaseError.GeocodingError(underlyingError)

                        expect(observerB.didFailWithUseCase) === subject as? StockEventsNearAddressUseCase
                        expect(observerB.didFailWithError) == EventsNearAddressUseCaseError.GeocodingError(underlyingError)
                    }
                }
            }
        }
    }
}

private class MockEventsNearAddressUseCaseObserver: EventsNearAddressUseCaseObserver {
    var didFindNoEventsWithUseCase: StockEventsNearAddressUseCase?
    private func eventsNearAddressUseCaseFoundNoEvents(useCase: EventsNearAddressUseCase) {
        didFindNoEventsWithUseCase = useCase as? StockEventsNearAddressUseCase
    }

    var didStartFetchingEventsWithUseCase: StockEventsNearAddressUseCase?
    private func eventsNearAddressUseCaseDidStartFetchingEvents(useCase: EventsNearAddressUseCase) {
        didStartFetchingEventsWithUseCase = useCase as? StockEventsNearAddressUseCase
    }

    var didFindEventsWithUseCase: StockEventsNearAddressUseCase?
    var didFindEvents: EventSearchResult?
    private func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFetchEventSearchResult searchResult: EventSearchResult) {
        didFindEventsWithUseCase = useCase as? StockEventsNearAddressUseCase
        didFindEvents = searchResult
    }

    var didFailWithUseCase: StockEventsNearAddressUseCase?
    var didFailWithError: EventsNearAddressUseCaseError?
    private func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFailFetchEvents error: EventsNearAddressUseCaseError) {
        didFailWithUseCase = useCase as? StockEventsNearAddressUseCase
        didFailWithError = error
    }
}
