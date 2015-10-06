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
    
    public func codersForSandersURL() -> NSURL! {
        return NSURL(string: "https://www.reddit.com/r/codersforsanders")!
    }
    
    public func designersForSandersURL() -> NSURL! {
        return NSURL(string: "https://www.reddit.com/r/designersforsanders")!
    }
    
    public func sandersForPresidentURL() -> NSURL! {
        return NSURL(string: "https://www.reddit.com/r/sandersforpresident")!
    }
    
    public func feedbackFormURL() -> NSURL! {
        let urlComponents = NSURLComponents(string: "https://docs.google.com/forms/d/1YtW1qhtXIb7rdiksI94XjsN6lJ8vkIGqH7LU0xLU_5Q/viewform")!
        let platformQueryItem = NSURLQueryItem(name: "entry.506", value: "iOS")
        
        let marketingVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let internalBuildNumber  = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
        let versionString = "\(marketingVersion) (\(internalBuildNumber))"
        let versionQueryItem = NSURLQueryItem(name: "entry.937851719", value: versionString)
        
        urlComponents.queryItems = [platformQueryItem, versionQueryItem]
        return urlComponents.URL
    }
}