import Foundation
import CoreLocation

struct Event {
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
    let url: NSURL
    let eventTypeName: String?

    init(name: String, startDate: NSDate, timeZone: NSTimeZone, attendeeCapacity: Int, attendeeCount: Int, streetAddress: String?, city: String, state: String, zip: String, location: CLLocation, description: String, url: NSURL, eventTypeName: String?) {
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
        self.url = url
        self.eventTypeName = eventTypeName
    }
}

extension Event: Equatable {}

func == (lhs: Event, rhs: Event) -> Bool {
    return lhs.name == rhs.name
    && lhs.startDate == rhs.startDate
    && lhs.timeZone == rhs.timeZone
    && lhs.attendeeCapacity == rhs.attendeeCapacity
    && lhs.attendeeCount == rhs.attendeeCount
    && lhs.streetAddress == rhs.streetAddress
    && lhs.city == rhs.city
    && lhs.state == rhs.state
    && lhs.zip == rhs.zip
    && lhs.location == rhs.location
    && lhs.description == rhs.description
    && lhs.url == rhs.url
    && lhs.eventTypeName == rhs.eventTypeName
}
