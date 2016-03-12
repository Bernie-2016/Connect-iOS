import Foundation
import CBGPromise
import CoreLocation

enum EventRepositoryError: ErrorType {
    case GeocodingError(error: NSError)
    case InvalidJSONError(jsonObject: AnyObject)
    case ErrorInJSONClient(error: JSONClientError)
}

typealias EventSearchResultFuture = Future<EventSearchResult, EventRepositoryError>
typealias EventSearchResultPromise = Promise<EventSearchResult, EventRepositoryError>

protocol EventRepository {
    func fetchEventsAroundLocation(location: CLLocation, radiusMiles: Float) -> EventSearchResultFuture
    func fetchEventsWithZipCode(zipCode: String, radiusMiles: Float) -> EventSearchResultFuture
}
