import Foundation
import CoreLocation

class ConcreteEventDeserializer: EventDeserializer {
    init() {}

    func deserializeEvents(jsonDictionary: NSDictionary) -> Array<Event> {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"  // "2015-08-28T05:10:21"

        var events = [Event]()

        let hitsDictionary = jsonDictionary["hits"] as? NSDictionary;

        if hitsDictionary == nil {
            return events
        }

        let eventsDictionaries = hitsDictionary!["hits"] as? Array<NSDictionary>;

        if eventsDictionaries == nil {
            return events
        }

        for eventDictionary: NSDictionary in eventsDictionaries! {
            var sourceDictionary = eventDictionary["_source"] as? [String:AnyObject];

            if sourceDictionary == nil {
                continue;
            }

            var venueDictionary = sourceDictionary!["venue"] as? [String:AnyObject];

            if venueDictionary == nil {
                continue;
            }

            var locationDictionary = venueDictionary!["location"] as? [String:CLLocationDegrees]

            if locationDictionary == nil {
                continue;
            }

            let name = sourceDictionary!["name"] as? String
            let timeZoneString = sourceDictionary!["timezone"] as? String
            let startDateString = sourceDictionary!["start_time"] as? String
            let attendeeCapacity = sourceDictionary!["capacity"] as? Int
            let attendeeCount = sourceDictionary!["attendee_count"] as? Int

            let streetAddress = venueDictionary!["address1"] as? String
            let city = venueDictionary!["city"] as? String
            let state = venueDictionary!["state"] as? String
            let zip = venueDictionary!["zip"] as? String
            let latitude = locationDictionary!["lat"]
            let longitude = locationDictionary!["lon"]
            let description = sourceDictionary!["description"] as? String
            let URLString = sourceDictionary!["url"] as? String

            if name == nil || timeZoneString == nil || startDateString == nil
                || attendeeCapacity == nil || attendeeCount == nil
                || city == nil || state == nil || zip == nil || latitude == nil || longitude == nil
                || description == nil || URLString == nil {
                continue;
            }

            let URL = NSURL(string: URLString!)
            let timeZone = NSTimeZone(abbreviation: timeZoneString!)

            if URL == nil || timeZone == nil {
                continue;
            }

            dateFormatter.timeZone = timeZone
            let startDate = dateFormatter.dateFromString(startDateString!)

            if startDate == nil {
                continue;
            }

            let location = CLLocation(latitude: latitude!, longitude: longitude!)
            let event = Event(name: name!, startDate: startDate!, timeZone: timeZone!, attendeeCapacity: attendeeCapacity!, attendeeCount: attendeeCount!,
                streetAddress: streetAddress, city: city!, state: state!, zip: zip!, location: location,
                description: description!, url: URL!)

            events.append(event)
        }

        return events
    }
}
