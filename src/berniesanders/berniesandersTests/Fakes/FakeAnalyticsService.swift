import Foundation
import berniesanders

class FakeAnalyticsService: AnalyticsService {
    var lastCustomEventName: String!
    
    func trackCustomEventWithName(name: String) {
        self.lastCustomEventName = name
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
        self.lastSearchQuery = query
        self.lastSearchContext = context
    }
}
