import Foundation

public class ConcreteEventDeserializer : EventDeserializer {
    public init() {
        
    }
    
    public func deserializeEvents(jsonDictionary: NSDictionary) -> Array<Event> {
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
            var attendeeCapacity = sourceDictionary!["capacity"] as? Int
            var attendeeCount = sourceDictionary!["attendee_count"] as? Int
            
            var city = venueDictionary!["city"] as? String
            var state = venueDictionary!["state"] as? String
            var zip = venueDictionary!["zip"] as? String
            var description = sourceDictionary!["description"] as? String
            var URLString = sourceDictionary!["url"] as? String
            
            if (name == nil || attendeeCapacity == nil || attendeeCount == nil
                || city == nil || state == nil || zip == nil
                || description == nil || URLString == nil) {
                continue;
            }
            
            var URL = NSURL(string: URLString!)
            
            if (URL == nil) {
                continue;
            }
            
            var event = Event(name: name!, attendeeCapacity: attendeeCapacity!, attendeeCount: attendeeCount!,
                city: city!, state: state!, zip: zip!, description: description!, URL: URL!)
            
            events.append(event)
        }
        
        return events
    }
}