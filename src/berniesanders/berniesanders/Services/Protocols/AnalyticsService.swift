import UIKit

public protocol AnalyticsService {
    func trackCustomEventWithName(name: String, customAttributes: [NSObject : AnyObject]?)
    func trackContentViewWithName(name: String, type: AnalyticsServiceContentType, id: String)
    func trackError(error: NSError, context: String)
    func trackShareWithActivityType(activityType: String, contentName: String, contentType: AnalyticsServiceContentType, id: String)
    func trackSearchWithQuery(query: String, context: AnalyticsSearchContext)
}

public struct AnalyticsServiceConstants {
    public static let contentIDKey = "contentID"
}

public enum AnalyticsServiceContentType : String, Printable {
    case NewsItem = "News Item"
    case Issue = "Issue"
    case Settings = "Settings"
    case Event = "Event"
    
    public var description: String {
        return self.rawValue
    }
}

public enum AnalyticsSearchContext : String, Printable {
    case Events = "Events"
    
    public var description: String {
        return self.rawValue
    }
}

