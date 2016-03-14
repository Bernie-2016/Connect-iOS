import Quick
import Nimble

@testable import Connect

class StockEventsNearAddressUseCaseSpec: QuickSpec {
    override func spec() {
        describe("StockEventsNearAddressUseCase") {
            var subject: EventsNearAddressUseCase!

            var observerA: MockEventsNearAddressUseCaseObserver!
            var observerB: MockEventsNearAddressUseCaseObserver!

            beforeEach {
                subject = StockEventsNearAddressUseCase()

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
            }
        }
    }

}

private class MockEventsNearAddressUseCaseObserver: EventsNearAddressUseCaseObserver {
    private func eventsNearAddressUseCaseFoundNoEvents(useCase: EventsNearAddressUseCase) {

    }

    var didStartFetchingEventsWithUseCase: StockEventsNearAddressUseCase?
    private func eventsNearAddressUseCaseDidStartFetchingEvents(useCase: EventsNearAddressUseCase) {
        didStartFetchingEventsWithUseCase = useCase as? StockEventsNearAddressUseCase
    }

    private func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFetchEventSearchResult: EventSearchResult) {

    }

    private func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFailFetchEvents: EventsNearAddressUseCaseError) {

    }
}
