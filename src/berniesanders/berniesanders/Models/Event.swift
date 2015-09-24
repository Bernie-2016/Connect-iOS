import Foundation

public class Event {
    public let name : String!
    public let attendeeCapacity : Int!
    public let attendeeCount : Int!
    public let city: String!
    public let state: String!
    public let zip: String!
    
    public init(name: String, attendeeCapacity: Int, attendeeCount: Int, city: String, state: String, zip: String) {
        self.name = name
        self.attendeeCapacity = attendeeCapacity
        self.attendeeCount = attendeeCount
        self.city = city
        self.state = state
        self.zip = zip
    }
}