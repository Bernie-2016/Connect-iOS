import Foundation
@testable import berniesanders

class FakeAnalyticsService: AnalyticsService {
    var lastBackButtonTapScreen: String!
    var lastBackButtonTapAttributes: [NSObject : AnyObject]?

    func trackBackButtonTapOnScreen(screen: String, customAttributes: [NSObject : AnyObject]?) {
        self.lastBackButtonTapScreen = screen
        self.lastBackButtonTapAttributes = customAttributes
    }

    var lastTrackedPageViewName: String!
    var lastTrackedPageViewAttributes: [NSObject: AnyObject]?

    func trackPageViewWithName(name: String, customAttributes: [NSObject: AnyObject]?) {
        self.lastTrackedPageViewName = name
        self.lastTrackedPageViewAttributes = customAttributes
    }

    var lastCustomEventName: String!
    var lastCustomEventAttributes: [NSObject : AnyObject]?

    func trackCustomEventWithName(name: String, customAttributes: [NSObject : AnyObject]?) {
        lastCustomEventName = name
        if(customAttributes != nil) {
            lastCustomEventAttributes = customAttributes!
        }
    }

    var lastContentViewName: String!
    var lastContentViewType: AnalyticsServiceContentType!
    var lastContentViewID: String!

    func trackContentViewWithName(name: String, type: AnalyticsServiceContentType, id: String) {
        lastContentViewName = name
        lastContentViewType = type
        lastContentViewID = id
    }

    var lastError: NSError!
    var lastErrorContext: String!

    func trackError(error: NSError, context: String) {
        lastError = error
        lastErrorContext = context
    }

    var lastShareActivityType: String!
    var lastShareContentName: String!
    var lastShareContentType: AnalyticsServiceContentType!
    var lastShareID: String!

    func trackShareWithActivityType(activityType: String, contentName: String, contentType: AnalyticsServiceContentType, id: String) {       lastShareActivityType = activityType
        lastShareContentName = contentName
        lastShareContentType = contentType
        lastShareID = id
    }

    var lastSearchQuery: String!
    var lastSearchContext: AnalyticsSearchContext!

    func trackSearchWithQuery(query: String, context: AnalyticsSearchContext) {
        lastSearchQuery = query
        lastSearchContext = context
    }

    var lastAnalyticsPermission: Bool!

    func updateAnalyticsPermission(permissionGranted: Bool) {
        lastAnalyticsPermission = permissionGranted
    }
}
