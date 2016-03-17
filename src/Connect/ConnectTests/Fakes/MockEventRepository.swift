import CoreLocation

@testable import Connect

class MockEventRepository: EventRepository {
    var didFetchEventsAroundLocation: CLLocation?
    var didFetchEventsWithRadiusMiles: Float?
    var lastReturnedPromise: EventSearchResultPromise!

    func fetchEventsAroundLocation(location: CLLocation, radiusMiles: Float) -> EventSearchResultFuture {
        didFetchEventsAroundLocation = location
        didFetchEventsWithRadiusMiles = radiusMiles
        lastReturnedPromise = EventSearchResultPromise()

        return lastReturnedPromise.future
    }
}

