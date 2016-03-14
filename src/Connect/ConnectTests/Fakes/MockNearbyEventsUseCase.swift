@testable import Connect

class MockNearbyEventsUseCase: NearbyEventsUseCase {
    var observers = [NearbyEventsUseCaseObserver]()

    func addObserver(observer: NearbyEventsUseCaseObserver) {
        observers.append(observer)
    }

    var didFetchNearbyEventsWithinRadius: Float?
    func fetchNearbyEventsWithinRadiusMiles(radiusMiles: Float) {
        didFetchNearbyEventsWithinRadius = radiusMiles

        for observer in observers {
            observer.nearbyEventsUseCaseDidStartFetchingEvents(self)
        }
    }

    func simulateFindingEvents(eventSearchResult: EventSearchResult) {
        for observer in observers {
            observer.nearbyEventsUseCase(self, didFetchEventSearchResult: eventSearchResult)
        }
    }

    func simulateFindingNoEvents() {
        for observer in observers {
            observer.nearbyEventsUseCaseFoundNoNearbyEvents(self)
        }
    }

    func simulateFailingToFindEvents(error: NearbyEventsUseCaseError) {
        for observer in observers {
            observer.nearbyEventsUseCase(self, didFailFetchEvents: error)
        }
    }
}
