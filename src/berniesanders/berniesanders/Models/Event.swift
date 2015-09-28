import Foundation
import CoreLocation

public class Event {
    public let name : String!
    public let startDate: NSDate!
    public let timeZone: NSTimeZone!
    public let attendeeCapacity : Int!
    public let attendeeCount : Int!
    public let streetAddress: String?
    public let city: String!
    public let state: String!
    public let zip: String!
    public let location : CLLocation!
    public let description: String!
    public let URL: NSURL!
    
    public init(name: String, startDate: NSDate, timeZone: NSTimeZone, attendeeCapacity: Int, attendeeCount: Int, streetAddress: String?, city: String, state: String, zip: String, location: CLLocation, description: String, URL: NSURL) {
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