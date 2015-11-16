import Foundation

#if RELEASE
    import Crashlytics
#endif

class ConcreteAnalyticsService: AnalyticsService {
    private let applicationSettingsRepository: ApplicationSettingsRepository

    init(applicationSettingsRepository: ApplicationSettingsRepository) {
            self.applicationSettingsRepository = applicationSettingsRepository
    }

    func trackBackButtonTapOnScreen(screen: String, customAttributes: [NSObject : AnyObject]?) {
        var attributes = ["fromScreen": screen]

        if customAttributes != nil {
            for (key, value) in customAttributes! {
                guard let keyAsString = key as? String else { continue }
                attributes[keyAsString] = value as? String
            }
        }

        trackCustomEventWithName("Tapped Back", customAttributes: attributes)
    }

    func trackCustomEventWithName(name: String, customAttributes: [NSObject : AnyObject]?) {
        self.applicationSettingsRepository.isAnalyticsEnabled { (analyticsEnabled) -> Void in
            if analyticsEnabled {
            #if RELEASE
                Answers.logCustomEventWithName(name, customAttributes: customAttributes)
                Flurry.logEvent(name, withParameters: customAttributes)
            #endif
            }
        }
    }

    func trackContentViewWithName(name: String, type: AnalyticsServiceContentType, id: String) {
        self.applicationSettingsRepository.isAnalyticsEnabled { (analyticsEnabled) -> Void in
            if analyticsEnabled {
                #if RELEASE
                    Answers.logContentViewWithName(name, contentType: type.description, contentId: id, customAttributes: nil)
                    let flurryParams = [ "name": name, "type": type.description, "id": id]
                    Flurry.logEvent("Content View", withParameters: flurryParams)
                #endif
            }
        }
    }

    func trackError(error: NSError, context: String) {
        self.applicationSettingsRepository.isAnalyticsEnabled { (analyticsEnabled) -> Void in
            if analyticsEnabled {
                #if RELEASE
                    Answers.logCustomEventWithName("\(context): \(error.description)", customAttributes: nil)
                    Flurry.logError(context, message: error.description, error: error)
                #endif
            }
        }
    }

    func trackShareWithActivityType(activityType: String, contentName: String, contentType: AnalyticsServiceContentType, id: String) {
        self.applicationSettingsRepository.isAnalyticsEnabled { (analyticsEnabled) -> Void in
            if analyticsEnabled {
                #if RELEASE
                    Answers.logShareWithMethod(activityType, contentName: contentName, contentType: contentType.description, contentId: id, customAttributes: nil)
                    let flurryParams = ["name": contentName, "type": contentType.description, "id": id]
                    Flurry.logEvent("Content share", withParameters: flurryParams)
                #endif
            }
        }
    }

    func trackSearchWithQuery(query: String, context: AnalyticsSearchContext) {
        self.applicationSettingsRepository.isAnalyticsEnabled { (analyticsEnabled) -> Void in
            if analyticsEnabled {
                #if RELEASE
                    Answers.logSearchWithQuery(query, customAttributes: [ "context": context.description ])
                    let flurryParams = ["query": query, "context": context.description]
                    Flurry.logEvent("Search", withParameters: flurryParams)
                #endif
            }
        }
    }
}
