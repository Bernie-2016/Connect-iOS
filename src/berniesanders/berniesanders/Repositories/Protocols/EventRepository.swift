import Foundation


protocol EventRepository {
    func fetchEventsWithZipCode(zipCode: String, radiusMiles: Float, completion: (Array<Event>) -> Void, error: (NSError) -> Void)
}
