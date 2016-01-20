import UIKit

protocol AnalyticsService {
    func trackCustomEventWithName(name: String, customAttributes: [NSObject : AnyObject]?)
    func trackPageViewWithName(name: String, customAttributes: [NSObject: AnyObject]?)
    func trackContentViewWithName(name: String, type: AnalyticsServiceContentType, identifier: String)
    func trackBackButtonTapOnScreen(screen: String, customAttributes: [NSObject : AnyObject]?)
    func trackError(error: ErrorType, context: String)
    func trackShareWithActivityType(activityType: String, contentName: String, contentType: AnalyticsServiceContentType, identifier: String)
    func trackSearchWithQuery(query: String, context: AnalyticsSearchContext)
}

struct AnalyticsServiceConstants {
    static let contentIDKey = "id"
    static let contentNameKey = "name"
    static let contentTypeKey = "type"
}

enum AnalyticsServiceContentType: String, CustomStringConvertible {
    case NewsArticle = "News Article"
    case Issue = "Issue"
    case Settings = "Settings"
    case Event = "Event"
    case Onboarding = "Onboarding"
    case About = "About"
    case TabBar = "Tab Bar"
    case Video = "Video"
    case Actions = "Actions"

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
