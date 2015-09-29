import Foundation
import CoreLocation

public class ConcreteURLProvider : URLProvider {
    public init() {}
    
    public func issuesFeedURL() -> NSURL! {
        return NSURL(string: "https://search.berniesanders.tech/articles_en/berniesanders_com/_search")
    }
    
    public func newsFeedURL() -> NSURL! {
        return NSURL(string: "https://search.berniesanders.tech/articles_en/berniesanders_com/_search")
    }
    
    public func bernieCrowdURL() -> NSURL! {
        return NSURL(string: "https://berniecrowd.org/")
    }
    
    public func privacyPolicyURL() -> NSURL! {
        return NSURL(string: "https://www.iubenda.com/privacy-policy/128001")
    }
    
    public func eventsURL() -> NSURL! {
        return NSURL(string: "https://search.berniesanders.tech/events/berniesanders_com/_search")
    }
    
    public func mapsURLForEvent(event: Event) -> NSURL! {
        if(event.streetAddress != nil) {
            let urlString = String(format: "https://maps.apple.com/?address=%@,%@,%@,%@", event.streetAddress!, event.city, event.state, event.zip)
            return NSURL(string: urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!
        } else {
            let urlString = String(format: "https://maps.apple.com/?address=%@,%@,%@", event.city, event.state, event.zip)
            return NSURL(string: urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!
        }
    }
}