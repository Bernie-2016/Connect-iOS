import Foundation

typealias Address = String

protocol EventsNearAddressUseCase {
    func fetchEventsNearAddress(address: Address, radiusMiles: Float)
}

class StockEventsNearAddressUseCase: EventsNearAddressUseCase {
    func fetchEventsNearAddress(address: Address, radiusMiles: Float) {

    }
}
