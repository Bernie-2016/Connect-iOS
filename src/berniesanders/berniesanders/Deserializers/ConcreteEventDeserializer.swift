import Foundation

public class ConcreteEventDeserializer : EventDeserializer {
    public init() {
        
    }
    
    public func deserializeEvents(jsonDictionary: NSDictionary) -> Array<Event> {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"  // "2015-08-28T05:10:21"
        // TODO: inject a dateformatter.

        
        var events = [Event]()

        var hitsDictionary = jsonDictionary["hits"] as? NSDictionary;

        if (hitsDictionary == nil) {
            return events
        }
        
        var eventsDictionaries = hitsDictionary!["hits"] as? Array<NSDictionary>;
        
        if (eventsDictionaries == nil) {
            return events
        }

        for(eventDictionary: NSDictionary) in eventsDictionaries! {
            var sourceDictionary = eventDictionary["_source"] as? [String:AnyObject];
            
            if(sourceDictionary == nil) {
                continue;
            }
            
            var venueDictionary = sourceDictionary!["venue"] as? [String:AnyObject];
            
            if(venueDictionary == nil) {
                continue;
            }
            
            var name = sourceDictionary!["name"] as? String
            var timeZoneString = sourceDictionary!["timezone"] as? String
            var startDateString = sourceDictionary!["start_time"] as? String
            var attendeeCapacity = sourceDictionary!["capacity"] as? Int
            var attendeeCount = sourceDictionary!["attendee_count"] as? Int
            
            var streetAddress = venueDictionary!["address1"] as? String
            var city = venueDictionary!["city"] as? String
            var state = venueDictionary!["state"] as? String
            var zip = venueDictionary!["zip"] as? String
            var description = sourceDictionary!["description"] as? String
            var URLString = sourceDictionary!["url"] as? String
            
            if (name == nil || timeZoneString == nil || startDateString == nil
                || attendeeCapacity == nil || attendeeCount == nil
                || city == nil || state == nil || zip == nil
                || description == nil || URLString == nil) {
                continue;
            }
            
            var URL = NSURL(string: URLString!)
            var timeZone = NSTimeZone(abbreviation: timeZoneString!)
            
            if (URL == nil || timeZone == nil) {
                continue;
            }

            dateFormatter.timeZone = timeZone
            var startDate = dateFormatter.dateFromString(startDateString!)
            
            if(startDate == nil) {
                continue;
            }

            
            var event = Event(name: name!, startDate: startDate!, timeZone: timeZone!, attendeeCapacity: attendeeCapacity!, attendeeCount: attendeeCount!,
                streetAddress: streetAddress, city: city!, state: state!, zip: zip!,
                description: description!, URL: URL!)
            
            events.append(event)
        }
        
        return events
    }
}