import Foundation
import CoreLocation

class Event {
    let name: String
    let startDate: NSDate
    let timeZone: NSTimeZone
    let attendeeCapacity: Int
    let attendeeCount: Int
    let streetAddress: String?
    let city: String
    let state: String
    let zip: String
    let location: CLLocation
    let description: String
    let URL: NSURL

    init(name: String, startDate: NSDate, timeZone: NSTimeZone, attendeeCapacity: Int, attendeeCount: Int, streetAddress: String?, city: String, state: String, zip: String, location: CLLocation, description: String, URL: NSURL) {
        self.name = name
        self.startDate = startDate
        self.timeZone = timeZone
        self.attendeeCapacity = attendeeCapacity
        self.attendeeCount = attendeeCount
        self.streetAddress = streetAddress
        self.city = city
        self.state = state
        self.zip = zip
        self.location = location
        self.description = description
        self.URL = URL
    }
}
