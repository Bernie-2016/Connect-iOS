import Foundation

enum NearbyEventsUseCaseError: ErrorType {
    case FindingLocationError(CurrentLocationUseCaseError)
}

protocol NearbyEventsUseCase {
    func addObserver(observer: NearbyEventsUseCaseObserver)
    func fetchNearbyEvents()
}

protocol NearbyEventsUseCaseObserver {
    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFetchEvents: [Event])
    func nearbyEventsUseCaseFoundNoNearbyEvents(useCase: NearbyEventsUseCase)
    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFailFetchEvents: NearbyEventsUseCaseError)
}


class StockNearbyEventsUseCase: NearbyEventsUseCase {
    func addObserver(observer: NearbyEventsUseCaseObserver) {

    }

    func fetchNearbyEvents() {

    }
}
