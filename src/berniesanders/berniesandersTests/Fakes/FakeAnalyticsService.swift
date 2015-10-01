import Foundation
import berniesanders

class FakeAnalyticsService : AnalyticsService {
    var lastCustomEventName : String!
    
    func trackCustomEventWithName(name: String) {
        self.lastCustomEventName = name
    }
}
