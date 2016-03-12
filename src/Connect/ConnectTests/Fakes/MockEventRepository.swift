import CoreLocation

@testable import Connect

class MockEventRepository: EventRepository {
    var lastReceivedZipCode: NSString?
    var lastReceivedRadiusMiles: Float?
    var lastReturnedPromise: EventSearchResultPromise!

    func fetchEventsWithZipCode(zipCode: String, radiusMiles: Float) -> EventSearchResultFuture {
        lastReceivedZipCode = zipCode
        lastReceivedRadiusMiles = radiusMiles
        lastReturnedPromise = EventSearchResultPromise()
        return lastReturnedPromise.future
    }

    var didFetchEventsAroundLocation: CLLocation?
    var didFetchEventsWithRadiusMiles: Float?

    func fetchEventsAroundLocation(location: CLLocation, radiusMiles: Float) -> EventSearchResultFuture {
        didFetchEventsAroundLocation = location
        didFetchEventsWithRadiusMiles = radiusMiles
        lastReturnedPromise = EventSearchResultPromise()

        return lastReturnedPromise.future
    }
}

