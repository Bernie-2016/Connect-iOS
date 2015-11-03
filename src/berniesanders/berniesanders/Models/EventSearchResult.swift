import Foundation
import CoreLocation

class EventSearchResult {
    let searchCentroid: CLLocation
    let events: Array<Event>

    init(searchCentroid: CLLocation, events: Array<Event>) {
        self.searchCentroid = searchCentroid
        self.events = events
    }
}
