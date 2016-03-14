import Foundation
import CBGPromise
import CoreLocation

enum EventRepositoryError: ErrorType {
    case GeocodingError(error: NSError)
    case InvalidJSONError(jsonObject: AnyObject)
    case ErrorInJSONClient(error: JSONClientError)
}

extension EventRepositoryError: Equatable {}

func == (lhs: EventRepositoryError, rhs: EventRepositoryError) -> Bool {
    switch (lhs, rhs) {
    case (.GeocodingError(let lhsError), .GeocodingError(let rhsError)):
        return lhsError._domain == rhsError._domain && lhsError._code == rhsError._code
    case (.InvalidJSONError, .InvalidJSONError):
        return true // punting \o/
    case (.ErrorInJSONClient(let lhsError), .ErrorInJSONClient(let rhsError)):
        return lhsError == rhsError
    default:
        return lhs._domain == rhs._domain && lhs._code == rhs._code
    }
}

typealias EventSearchResultFuture = Future<EventSearchResult, EventRepositoryError>
typealias EventSearchResultPromise = Promise<EventSearchResult, EventRepositoryError>

protocol EventRepository {
    func fetchEventsAroundLocation(location: CLLocation, radiusMiles: Float) -> EventSearchResultFuture
    func fetchEventsWithZipCode(zipCode: String, radiusMiles: Float) -> EventSearchResultFuture
}
