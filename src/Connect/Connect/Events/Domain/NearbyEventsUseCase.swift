import Foundation

enum NearbyEventsUseCaseError: ErrorType {
    case FindingLocationError(CurrentLocationUseCaseError)
    case FetchingEventsError(EventRepositoryError)
}

extension NearbyEventsUseCaseError: Equatable {}

func == (lhs: NearbyEventsUseCaseError, rhs: NearbyEventsUseCaseError) -> Bool {
    switch (lhs, rhs) {
    case (.FindingLocationError(let lhsError), .FindingLocationError(let rhsError)):
        return lhsError == rhsError
    default:
        return lhs._domain == rhs._domain && lhs._code == rhs._code
    }
}

protocol NearbyEventsUseCase {
    func addObserver(observer: NearbyEventsUseCaseObserver)
    func fetchNearbyEventsWithinRadiusMiles(radiusMiles: Float)
}

protocol NearbyEventsUseCaseObserver :class {
    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFetchEventSearchResult: EventSearchResult)
    func nearbyEventsUseCaseFoundNoNearbyEvents(useCase: NearbyEventsUseCase)
    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFailFetchEvents: NearbyEventsUseCaseError)
}


class StockNearbyEventsUseCase: NearbyEventsUseCase {
    private let currentLocationUseCase: CurrentLocationUseCase
    private let eventRepository: EventRepository

    private let _observers = NSHashTable.weakObjectsHashTable()
    private var observers: [NearbyEventsUseCaseObserver] {
        return _observers.allObjects.flatMap { $0 as? NearbyEventsUseCaseObserver }
    }
    init(currentLocationUseCase: CurrentLocationUseCase, eventRepository: EventRepository) {
        self.currentLocationUseCase = currentLocationUseCase
        self.eventRepository = eventRepository
    }

    func addObserver(observer: NearbyEventsUseCaseObserver) {
        _observers.addObject(observer)
    }

    func fetchNearbyEventsWithinRadiusMiles(radiusMiles: Float) {
        currentLocationUseCase.fetchCurrentLocation({ (location) -> () in
            let future = self.eventRepository.fetchEventsAroundLocation(location, radiusMiles: radiusMiles)
            future.then({ (searchResult) -> () in
                for observer in self.observers {
                    observer.nearbyEventsUseCase(self, didFetchEventSearchResult: searchResult)
                }
            })

            future.error({ (error) -> () in
                for observer in self.observers {
                    observer.nearbyEventsUseCase(self, didFailFetchEvents: .FetchingEventsError(error))
                }
            })

            }) { (error) -> () in
                for observer in self.observers {
                    observer.nearbyEventsUseCase(self, didFailFetchEvents: .FindingLocationError(error))
                }
        }
    }
}
