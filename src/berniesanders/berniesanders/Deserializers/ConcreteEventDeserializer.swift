import Foundation
import CoreLocation

class ConcreteEventDeserializer: EventDeserializer {
    private let stringContentSanitizer: StringContentSanitizer
    private let dateFormatter: NSDateFormatter

    init(stringContentSanitizer: StringContentSanitizer) {
        self.stringContentSanitizer = stringContentSanitizer
        self.dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"  // "2015-08-28T05:10:21"
    }

    // swiftlint:disable function_body_length
    func deserializeEvents(jsonDictionary: NSDictionary) -> Array<Event> {
        var events = [Event]()

        guard let eventsDictionaries = self.deserializeEventsDictionaries(jsonDictionary) else {
            return events
        }

        for eventDictionary: NSDictionary in eventsDictionaries {
            guard var sourceDictionary = eventDictionary["_source"] as? [String:AnyObject] else { continue }
            guard var venueDictionary = sourceDictionary["venue"] as? [String:AnyObject] else { continue }
            guard let locationDictionary = venueDictionary["location"] as? [String:CLLocationDegrees] else { continue }

            guard var name = sourceDictionary["name"] as? String else { continue }
            name = self.stringContentSanitizer.sanitizeString(name)
            guard let timeZoneString = sourceDictionary["timezone"] as? String else { continue }
            guard let startDateString = sourceDictionary["start_time"] as? String else { continue }
            guard let attendeeCapacity = sourceDictionary["capacity"] as? Int else { continue }
            guard let attendeeCount = sourceDictionary["attendee_count"] as? Int else { continue }
            var eventTypeName = sourceDictionary["event_type_name"] as? String
            if eventTypeName != nil { eventTypeName = self.stringContentSanitizer.sanitizeString(eventTypeName!) }

            var streetAddress = venueDictionary["address1"] as? String
            if streetAddress != nil { streetAddress = self.stringContentSanitizer.sanitizeString(streetAddress!) }
            guard var city = venueDictionary["city"] as? String else { continue }
            city = self.stringContentSanitizer.sanitizeString(city)
            guard var state = venueDictionary["state"] as? String else { continue }
            state = self.stringContentSanitizer.sanitizeString(state)
            guard let zip = venueDictionary["zip"] as? String else { continue }
            guard var description = sourceDictionary["description"] as? String else { continue }
            description = self.stringContentSanitizer.sanitizeString(description)
            guard let URLString = sourceDictionary["url"] as? String else { continue }
            guard let location = self.deserializeLocation(locationDictionary) else { continue }
            guard let URL = NSURL(string: URLString) else { continue }
            guard let timeZone = NSTimeZone(abbreviation: timeZoneString) else { continue }

            self.dateFormatter.timeZone = timeZone
            guard let startDate = self.dateFormatter.dateFromString(startDateString) else { continue }

            let event = Event(name: name, startDate: startDate, timeZone: timeZone, attendeeCapacity: attendeeCapacity, attendeeCount: attendeeCount,
                streetAddress: streetAddress, city: city, state: state, zip: zip, location: location,
                description: description, url: URL, eventTypeName: eventTypeName)

            events.append(event)
        }

        return events
    }
    // swiftlint:enable function_body_length

    // MARK: Private

    func deserializeEventsDictionaries(jsonDictionary: NSDictionary) -> Array<NSDictionary>? {
        guard let hitsDictionary = jsonDictionary["hits"] as? NSDictionary else { return nil }
        return hitsDictionary["hits"] as? Array<NSDictionary>
    }

    func deserializeLocation(locationDictionary: [String:CLLocationDegrees]) -> CLLocation? {
        guard let latitude = locationDictionary["lat"] else { return nil }
        guard let longitude = locationDictionary["lon"] else { return nil }
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
