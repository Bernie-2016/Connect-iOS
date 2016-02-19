import Foundation
import CBGPromise

protocol EventService {
    func fetchEventsWithZipCode(zipCode: String, radiusMiles: Float) -> EventSearchResultFuture
}
