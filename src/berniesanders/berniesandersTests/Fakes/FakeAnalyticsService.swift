import Foundation
import berniesanders

class FakeAnalyticsService: AnalyticsService {
    var lastCustomEventName: String!
    
    var lastContentViewName: String!
    var lastContentViewType: AnalyticsServiceContentType!
    var lastContentViewID: String!
    
    func trackCustomEventWithName(name: String) {
        self.lastCustomEventName = name
    }
    
    func trackContentViewWithName(name: String, type: AnalyticsServiceContentType, id: String) {
        self.lastContentViewName = name
        self.lastContentViewType = type
        self.lastContentViewID = id
    }
}
