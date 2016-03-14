import Foundation

typealias Address = String

enum EventsNearAddressUseCaseError: ErrorType {
    case FetchingEventsError(EventRepositoryError)
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
    }
}
