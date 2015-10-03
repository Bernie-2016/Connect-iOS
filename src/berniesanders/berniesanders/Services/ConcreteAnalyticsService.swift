import Foundation

class ConcreteAnalyticsService : AnalyticsService {
    func trackCustomEventWithName(name: String) {
        
    }
    
    func trackContentViewWithName(name: String, type: AnalyticsServiceContentType, id: String) {

    }
    
    func trackError(error: NSError, context: String) {

    }
    
    func trackShareWithActivityType(activityType: String, contentName: String, contentType: AnalyticsServiceContentType, id: String) {
        
    }
    
    func trackSearchWithQuery(query: String, context: AnalyticsSearchContext) {

    }
}