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
        self.lastContentViewName = name
        self.lastContentViewType = type
        self.lastContentViewID = id
    }
    
    var lastError: NSError!
    var lastErrorContext: String!
    
    func trackError(error: NSError, context: String) {
        self.lastError = error
        self.lastErrorContext = context
    }
}
