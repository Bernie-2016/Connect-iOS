import Foundation
import CoreLocation

typealias Address = String

enum EventsNearAddressUseCaseError: ErrorType {
    case GeocodingError(NSError)
    case FetchingEventsError(EventRepositoryError)
}

extension EventsNearAddressUseCaseError: Equatable {}

func == (lhs: EventsNearAddressUseCaseError, rhs: EventsNearAddressUseCaseError) -> Bool {
    switch (lhs, rhs) {
    case (.GeocodingError(let lhsError), .GeocodingError(let rhsError)):
        return lhsError._domain == rhsError._domain && lhsError._code == rhsError._code
    case (.FetchingEventsError(let lhsError), .FetchingEventsError(let rhsError)):
        return lhsError == rhsError
    default:
        return lhs._domain == rhs._domain && lhs._code == rhs._code
    }
}

protocol EventsNearAddressUseCase {
    func addObserver(observer: EventsNearAddressUseCaseObserver)
    func fetchEventsNearAddress(address: Address, radiusMiles: Float)
}

protocol EventsNearAddressUseCaseObserver :class {
    func eventsNearAddressUseCaseDidStartFetchingEvents(useCase: EventsNearAddressUseCase)
    func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFetchEventSearchResult: EventSearchResult)
    func eventsNearAddressUseCaseFoundNoEvents(useCase: EventsNearAddressUseCase)
    func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFailFetchEvents: EventsNearAddressUseCaseError)
}

class StockEventsNearAddressUseCase: EventsNearAddressUseCase {
    private let geocoder: CLGeocoder
    private let eventRepository: EventRepository

    init(
        geocoder: CLGeocoder,
        eventRepository: EventRepository) {
            self.geocoder = geocoder
            self.eventRepository = eventRepository
    }


    private let _observers = NSHashTable.weakObjectsHashTable()
    private var observers: [EventsNearAddressUseCaseObserver] {
        return _observers.allObjects.flatMap { $0 as? EventsNearAddressUseCaseObserver }
    }

    func addObserver(observer: EventsNearAddressUseCaseObserver) {
        _observers.addObject(observer)
    }

    func fetchEventsNearAddress(address: Address, radiusMiles: Float) {
        for observer in observers {
            observer.eventsNearAddressUseCaseDidStartFetchingEvents(self)
        }

        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                self.notifyObserversOfFailure(.GeocodingError(error))
                return
            }

            let placemark = placemarks!.first!
            let eventsFuture = self.eventRepository.fetchEventsAroundLocation(placemark.location!, radiusMiles: radiusMiles)

            eventsFuture.then { searchResult in
                if searchResult.events.count == 0 {
                    self.notifyObserversOfNoResults()
                } else {
                    self.notifyObserversWithSearchResult(searchResult)
                }
            }

            eventsFuture.error { error in
                self.notifyObserversOfFailure(.FetchingEventsError(error))
            }
        }
    }

    private func notifyObserversOfFailure(error: EventsNearAddressUseCaseError) {
        for observer in observers {
            observer.eventsNearAddressUseCase(self, didFailFetchEvents: error)
        }
    }

    private func notifyObserversOfNoResults() {
        for observer in observers {
            observer.eventsNearAddressUseCaseFoundNoEvents(self)
        }
    }

    private func notifyObserversWithSearchResult(searchResult: EventSearchResult) {
        for observer in observers {
            observer.eventsNearAddressUseCase(self, didFetchEventSearchResult: searchResult)
        }
    }
}
