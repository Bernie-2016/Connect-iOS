import Quick
import Nimble
import CoreLocation

@testable import Connect

class StockNearbyEventsUseCaseSpec: QuickSpec {
    override func spec() {
        describe("StockNearbyEventsUseCase") {
            var subject: NearbyEventsUseCase!
            var currentLocationUseCase: MockCurrentLocationUseCase!
            var eventRepository: MockEventRepository!

            var observerA: MockNearbyEventsUseCaseObserver!
            var observerB: MockNearbyEventsUseCaseObserver!
            beforeEach {
                currentLocationUseCase = MockCurrentLocationUseCase()
                eventRepository = MockEventRepository()

                subject = StockNearbyEventsUseCase(
                    currentLocationUseCase: currentLocationUseCase,
                    eventRepository: eventRepository
                )

                observerA = MockNearbyEventsUseCaseObserver()
                observerB = MockNearbyEventsUseCaseObserver()

                subject.addObserver(observerA)
                subject.addObserver(observerB)
            }

            describe("fetching nearby events") {
                it("asks the current location use case for the current location") {
                    subject.fetchNearbyEventsWithinRadiusMiles(42.0)

                    expect(currentLocationUseCase.didFetchCurrentLocation) == true
                }

                it("informs its observers that it has started fetching locations") {
                    subject.fetchNearbyEventsWithinRadiusMiles(42.0)

                    expect(observerA.didStartFetchingEventsWithUseCase) === subject as? StockNearbyEventsUseCase
                    expect(observerB.didStartFetchingEventsWithUseCase) === subject as? StockNearbyEventsUseCase
                }

                context("when the current location use case calls the success handler with a location") {
                    beforeEach {
                        subject.fetchNearbyEventsWithinRadiusMiles(42.0)
                    }

                    it("asks the events repository to fetch events around the location with the given radius") {
                        let expectedLocation = CLLocation(latitude: 1, longitude: 3)
                        currentLocationUseCase.simulateFoundLocation(expectedLocation)

                        expect(eventRepository.didFetchEventsAroundLocation) === expectedLocation
                        expect(eventRepository.didFetchEventsWithRadiusMiles) == 42.0
                    }

                    context("when the event repository resolves its promise with some events") {
                        let location = CLLocation(latitude: 1, longitude: 2)

                        beforeEach {
                            currentLocationUseCase.simulateFoundLocation(location)
                        }

                        it("notifies its observers with those events") {
                            let events = [TestUtils.eventWithName("event b"), TestUtils.eventWithName("event b")]
                            let expectedEventSearchResult = EventSearchResult(events: events)

                            eventRepository.lastReturnedPromise.resolve(expectedEventSearchResult)

                            expect(observerA.didFindNearbyEventsWithUseCase) === subject as? StockNearbyEventsUseCase
                            expect(observerB.didFindNearbyEventsWithSearchResult) === expectedEventSearchResult

                            expect(observerB.didFindNearbyEventsWithUseCase) === subject as? StockNearbyEventsUseCase
                            expect(observerB.didFindNearbyEventsWithSearchResult) === expectedEventSearchResult
                        }
                    }

                    context("when the event repository resolves its promise with zero events") {
                        let location = CLLocation(latitude: 1, longitude: 2)

                        beforeEach {
                            currentLocationUseCase.simulateFoundLocation(location)
                        }

                        it("notifies its observers with those events") {
                            let expectedEventSearchResult = EventSearchResult(events: [])

                            eventRepository.lastReturnedPromise.resolve(expectedEventSearchResult)

                            expect(observerA.didFindNoEventsWithUseCase) === subject as? StockNearbyEventsUseCase
                            expect(observerB.didFindNoEventsWithUseCase) === subject as? StockNearbyEventsUseCase
                        }
                    }

                    context("when the event repository rejects its promise with an error") {
                        beforeEach {
                            let location = CLLocation(latitude: 1, longitude: 2)
                            currentLocationUseCase.simulateFoundLocation(location)
                        }

                        it("notifies its observers with a wrapped error") {
                            let underlyingError = EventRepositoryError.InvalidJSONError(jsonObject: [])

                            eventRepository.lastReturnedPromise.reject(underlyingError)

                            expect(observerA.didFailToFindEventsWithUseCase) === subject as? StockNearbyEventsUseCase
                            expect(observerB.fetchEventsFailureError) == NearbyEventsUseCaseError.FetchingEventsError(underlyingError)

                            expect(observerB.didFailToFindEventsWithUseCase) === subject as? StockNearbyEventsUseCase
                            expect(observerB.fetchEventsFailureError) == NearbyEventsUseCaseError.FetchingEventsError(underlyingError)
                        }
                    }

                }

                context("when the current location use case calls the error handler with an error") {
                    beforeEach {
                        subject.fetchNearbyEventsWithinRadiusMiles(42.0)
                    }

                    it("notifies its delegates of failure") {
                        let underlyingError = CurrentLocationUseCaseError.PermissionsError

                        currentLocationUseCase.simulateFailure(underlyingError)

                        expect(observerA.didFailToFindEventsWithUseCase) === subject as? StockNearbyEventsUseCase
                        expect(observerA.fetchEventsFailureError) == NearbyEventsUseCaseError.FindingLocationError(underlyingError)
                        expect(observerB.didFailToFindEventsWithUseCase) === subject as? StockNearbyEventsUseCase
                        expect(observerB.fetchEventsFailureError) == NearbyEventsUseCaseError.FindingLocationError(underlyingError)
                    }
                }
            }
        }
    }
}

private class MockCurrentLocationUseCase: CurrentLocationUseCase {
    var successHandlers: [(CLLocation) -> ()] = []
    var errorHandlers: [(CurrentLocationUseCaseError) -> ()] = []

    var didFetchCurrentLocation = false
    private func fetchCurrentLocation(successHandler: (CLLocation) -> (), errorHandler: (CurrentLocationUseCaseError) -> ()) {
        didFetchCurrentLocation = true
        successHandlers.append(successHandler)
        errorHandlers.append(errorHandler)
    }

    private func simulateFoundLocation(location: CLLocation) {
        for handler in successHandlers {
            handler(location)
        }
    }

    private func simulateFailure(error: CurrentLocationUseCaseError) {
        for handler in errorHandlers {
            handler(error)
        }
    }
}

private class MockNearbyEventsUseCaseObserver: NearbyEventsUseCaseObserver {
    var didFindNearbyEventsWithUseCase: StockNearbyEventsUseCase?
    var didFindNearbyEventsWithSearchResult: EventSearchResult?

    private func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFetchEventSearchResult searchResult: EventSearchResult) {
        didFindNearbyEventsWithUseCase = useCase as? StockNearbyEventsUseCase
        didFindNearbyEventsWithSearchResult = searchResult
    }

    var didFailToFindEventsWithUseCase: StockNearbyEventsUseCase?
    var fetchEventsFailureError: NearbyEventsUseCaseError?
    private func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFailFetchEvents error: NearbyEventsUseCaseError) {
        didFailToFindEventsWithUseCase = useCase as? StockNearbyEventsUseCase
        fetchEventsFailureError = error
    }

    var didFindNoEventsWithUseCase: StockNearbyEventsUseCase?
    private func nearbyEventsUseCaseFoundNoNearbyEvents(useCase: NearbyEventsUseCase) {
        didFindNoEventsWithUseCase = useCase as? StockNearbyEventsUseCase
    }

    var didStartFetchingEventsWithUseCase: StockNearbyEventsUseCase?
    private func nearbyEventsUseCaseDidStartFetchingEvents(useCase: NearbyEventsUseCase) {
        didStartFetchingEventsWithUseCase = useCase as? StockNearbyEventsUseCase
    }

}
