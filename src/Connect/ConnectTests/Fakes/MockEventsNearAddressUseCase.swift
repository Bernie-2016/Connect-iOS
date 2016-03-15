@testable import Connect

class MockEventsNearAddressUseCase: EventsNearAddressUseCase {
    var lastSearchedAddress: String?
    var lastSearchedRadius: Float?
    func fetchEventsNearAddress(address: Address, radiusMiles: Float) {
        lastSearchedAddress = address
        lastSearchedRadius = radiusMiles
    }

    var observers: [EventsNearAddressUseCaseObserver] = []
    func addObserver(observer: EventsNearAddressUseCaseObserver) {
        observers.append(observer)
    }

    func simulateStartOfFetch() {
        for observer in observers {
            observer.eventsNearAddressUseCaseDidStartFetchingEvents(self, address: "simulated address")
        }
    }

    func simulateFindingEvents(eventSearchResult: EventSearchResult) {
        for observer in observers {
            observer.eventsNearAddressUseCase(self, didFetchEventSearchResult: eventSearchResult, address: "")
        }
    }

    func simulateFindingNoEvents() {
        for observer in observers {
            observer.eventsNearAddressUseCaseFoundNoEvents(self, address: "")
        }
    }

    func simulateFailingToFindEvents(error: EventsNearAddressUseCaseError) {
        for observer in observers {
            observer.eventsNearAddressUseCase(self, didFailFetchEvents: error, address: "")
        }
    }
}
