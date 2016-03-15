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
    func eventsNearAddressUseCaseDidStartFetchingEvents(useCase: EventsNearAddressUseCase, address: Address)
    func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFetchEventSearchResult eventSearchResult: EventSearchResult, address: Address)
    func eventsNearAddressUseCaseFoundNoEvents(useCase: EventsNearAddressUseCase, address: Address)
    func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFailFetchEvents error: EventsNearAddressUseCaseError, address: Address)
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
            observer.eventsNearAddressUseCaseDidStartFetchingEvents(self, address: address)
        }

        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                self.notifyObserversOfFailure(.GeocodingError(error), address: address)
                return
            }

            let placemark = placemarks!.first!
            let eventsFuture = self.eventRepository.fetchEventsAroundLocation(placemark.location!, radiusMiles: radiusMiles)

            eventsFuture.then { searchResult in
                if searchResult.events.count == 0 {
                    self.notifyObserversOfNoResults(address)
                } else {
                    self.notifyObserversWithSearchResult(searchResult, address: address)
                }
            }

            eventsFuture.error { error in
                self.notifyObserversOfFailure(.FetchingEventsError(error), address: address)
            }
        }
    }

    private func notifyObserversOfFailure(error: EventsNearAddressUseCaseError, address: Address) {
        for observer in observers {
            observer.eventsNearAddressUseCase(self, didFailFetchEvents: error, address: address)
        }
    }

    private func notifyObserversOfNoResults(address: Address) {
        for observer in observers {
            observer.eventsNearAddressUseCaseFoundNoEvents(self, address: address)
        }
    }

    private func notifyObserversWithSearchResult(searchResult: EventSearchResult, address: Address) {
        for observer in observers {
            observer.eventsNearAddressUseCase(self, didFetchEventSearchResult: searchResult, address: address)
        }
    }
}
