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
    func addObserver(observer: EventsNearAddressUseCaseObserver) {

    }

    func fetchEventsNearAddress(address: Address, radiusMiles: Float) {

    }
}
