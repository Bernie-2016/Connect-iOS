import Foundation
import CBGPromise

typealias EventSearchResultFuture = Future<EventSearchResult, NSError>
typealias EventSearchResultPromise = Promise<EventSearchResult, NSError>

protocol EventService {
    func fetchEventsWithZipCode(zipCode: String, radiusMiles: Float) -> EventSearchResultFuture
}
