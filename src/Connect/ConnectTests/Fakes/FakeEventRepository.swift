@testable import Connect

class FakeEventRepository : EventRepository {
    var lastReceivedZipCode : NSString?
    var lastReceivedRadiusMiles : Float?
    var lastReturnedPromise: EventSearchResultPromise!

    func fetchEventsWithZipCode(zipCode: String, radiusMiles: Float) -> EventSearchResultFuture {
        lastReceivedZipCode = zipCode
        lastReceivedRadiusMiles = radiusMiles
        lastReturnedPromise = EventSearchResultPromise()
        return lastReturnedPromise.future
    }
}

