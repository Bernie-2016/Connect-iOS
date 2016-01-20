import Foundation
import CBGPromise

enum EventRepositoryError: ErrorType {
    case GeocodingError(error: NSError)
    case InvalidJSONError(jsonObject: AnyObject)
    case ErrorInJSONClient(error: JSONClientError)
}

typealias EventSearchResultFuture = Future<EventSearchResult, EventRepositoryError>
typealias EventSearchResultPromise = Promise<EventSearchResult, EventRepositoryError>

protocol EventRepository {
    func fetchEventsWithZipCode(zipCode: String, radiusMiles: Float) -> EventSearchResultFuture
}
