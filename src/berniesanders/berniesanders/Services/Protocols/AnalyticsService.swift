import UIKit

protocol AnalyticsService {
    func trackCustomEventWithName(name: String, customAttributes: [NSObject : AnyObject]?)
    func trackContentViewWithName(name: String, type: AnalyticsServiceContentType, id: String)
    func trackBackButtonTapOnScreen(screen: String, customAttributes: [NSObject : AnyObject]?)
    func trackError(error: NSError, context: String)
    func trackShareWithActivityType(activityType: String, contentName: String, contentType: AnalyticsServiceContentType, id: String)
    func trackSearchWithQuery(query: String, context: AnalyticsSearchContext)
}

struct AnalyticsServiceConstants {
    static let contentIDKey = "contentID"
}

enum AnalyticsServiceContentType: String, CustomStringConvertible {
    case NewsItem = "News Item"
    case Issue = "Issue"
    case Settings = "Settings"
    case Event = "Event"
    case Onboarding = "Onboarding"

    var description: String {
        return self.rawValue
    }
}

enum AnalyticsSearchContext: String, CustomStringConvertible {
    case Events = "Events"

    var description: String {
        return self.rawValue
    }
}
