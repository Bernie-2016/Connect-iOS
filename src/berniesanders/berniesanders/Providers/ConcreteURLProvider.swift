import Foundation
import CoreLocation

class ConcreteURLProvider : URLProvider {
    func issuesFeedURL() -> NSURL! {
        return NSURL(string: "https://search.berniesanders.tech/articles_en/berniesanders_com/_search")
    }
    
    func newsFeedURL() -> NSURL! {
        return NSURL(string: "https://search.berniesanders.tech/articles_en/berniesanders_com/_search")
    }
    
    func bernieCrowdURL() -> NSURL! {
        return NSURL(string: "https://berniecrowd.org/")
    }
    
    func privacyPolicyURL() -> NSURL! {
        return NSURL(string: "https://www.iubenda.com/privacy-policy/128001")
    }
    
    func eventsURL() -> NSURL! {
        return NSURL(string: "https://search.berniesanders.tech/events/berniesanders_com/_search")
    }
}