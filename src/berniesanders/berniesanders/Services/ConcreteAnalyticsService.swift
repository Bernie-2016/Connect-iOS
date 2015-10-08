import Foundation

#if RELEASE
    import Crashlytics
#endif

class ConcreteAnalyticsService : AnalyticsService {
    let applicationSettingsRepository: ApplicationSettingsRepository
    
    init(applicationSettingsRepository: ApplicationSettingsRepository) {
            self.applicationSettingsRepository = applicationSettingsRepository
    }
    
    func trackCustomEventWithName(name: String, customAttributes: [NSObject : AnyObject]?) {
        self.applicationSettingsRepository.isAnalyticsEnabled { (analyticsEnabled) -> Void in
            if(analyticsEnabled) {
            #if RELEASE
                Answers.logCustomEventWithName(name, customAttributes: nil)
            #endif
            }
        }
    }
    
    func trackContentViewWithName(name: String, type: AnalyticsServiceContentType, id: String) {
        self.applicationSettingsRepository.isAnalyticsEnabled { (analyticsEnabled) -> Void in
            if(analyticsEnabled) {
                #if RELEASE
                    Answers.logContentViewWithName(name, contentType: type.description, contentId: id, customAttributes: nil)
                #endif
            }
        }
    }
    
    func trackError(error: NSError, context: String) {
        self.applicationSettingsRepository.isAnalyticsEnabled { (analyticsEnabled) -> Void in
            if(analyticsEnabled) {
                #if RELEASE
                    Answers.logCustomEventWithName("\(context): \(error.description)", customAttributes: nil)
                #endif
            }
        }
    }
    
    func trackShareWithActivityType(activityType: String, contentName: String, contentType: AnalyticsServiceContentType, id: String) {
        self.applicationSettingsRepository.isAnalyticsEnabled { (analyticsEnabled) -> Void in
            if(analyticsEnabled) {
                #if RELEASE
                    Answers.logShareWithMethod(activityType, contentName: contentName, contentType: contentType.description, contentId: id, customAttributes: nil)
                #endif
            }
        }
    }
    
    func trackSearchWithQuery(query: String, context: AnalyticsSearchContext) {
        self.applicationSettingsRepository.isAnalyticsEnabled { (analyticsEnabled) -> Void in
            if(analyticsEnabled) {
                #if RELEASE
                    Answers.logSearchWithQuery(query, customAttributes: [ "context": context.description ])
                #endif
            }
        }
    }
}