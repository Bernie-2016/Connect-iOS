import Foundation


protocol EventRepository {
    func fetchEventsWithZipCode(zipCode: String, radiusMiles: Float, completion: (EventSearchResult) -> Void, error: (NSError) -> Void)
}
