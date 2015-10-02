import UIKit

public protocol AnalyticsService {
    func trackCustomEventWithName(name: String)
    func trackContentViewWithName(name: String, type: AnalyticsServiceContentType, id: String)
    func trackError(error: NSError, context: String)
    func trackShareWithActivityType(activityType: String, contentName: String, contentType: AnalyticsServiceContentType, id: String)
}

public enum AnalyticsServiceContentType : String, Printable {
    case NewsItem = "News Item"
    case Issue = "Issue"
    
    public var description: String {
        return self.rawValue
    }
}

