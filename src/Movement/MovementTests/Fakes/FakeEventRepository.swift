@testable import Movement

class FakeEventRepository : EventRepository {
    var lastReceivedZipCode : NSString?
    var lastReceivedRadiusMiles : Float?
    var lastCompletionBlock: ((EventSearchResult) -> Void)?
    var lastErrorBlock: ((EventRepositoryError) -> Void)?

    func fetchEventsWithZipCode(zipCode: String, radiusMiles: Float, completion: (EventSearchResult) -> Void, error: (EventRepositoryError) -> Void) {
        self.lastReceivedZipCode = zipCode
        self.lastReceivedRadiusMiles = radiusMiles
        self.lastCompletionBlock = completion
        self.lastErrorBlock = error
    }
}

