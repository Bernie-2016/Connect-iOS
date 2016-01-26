import Foundation

#if RELEASE
    import Crashlytics
#endif

class ConcreteAnalyticsService: AnalyticsService {
    private let applicationSettingsRepository: ApplicationSettingsRepository

    init(applicationSettingsRepository: ApplicationSettingsRepository, apiKeyProvider: APIKeyProvider) {
            self.applicationSettingsRepository = applicationSettingsRepository
        #if RELEASE
            Flurry.startSession(apiKeyProvider.flurryAPIKey())
        #endif
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

    func trackPageViewWithName(name: String, customAttributes: [NSObject: AnyObject]?) {
        var attributes = ["pageName": name]

        if customAttributes != nil {
            for (key, value) in customAttributes! {
                guard let keyAsString = key as? String else { continue }
                attributes[keyAsString] = value as? String
            }
        }

        trackCustomEventWithName("Page View", customAttributes: attributes)
    }

    func trackCustomEventWithName(name: String, customAttributes: [NSObject : AnyObject]?) {
        self.applicationSettingsRepository.isAnalyticsEnabled { (analyticsEnabled) -> Void in
            if analyticsEnabled {
            #if RELEASE
                Flurry.logEvent(name, withParameters: customAttributes)
            #endif
            }
        }
    }

    func trackContentViewWithName(name: String, type: AnalyticsServiceContentType, identifier: String) {
        self.applicationSettingsRepository.isAnalyticsEnabled { (analyticsEnabled) -> Void in
            if analyticsEnabled {
                #if RELEASE
                    let flurryParams = [ "name": name, "type": type.description, "id": identifier]
                    Flurry.logEvent("Content View", withParameters: flurryParams)
                #endif
            }
        }
    }

    func trackError(error: ErrorType, context: String) {
        self.applicationSettingsRepository.isAnalyticsEnabled { (analyticsEnabled) -> Void in
            if analyticsEnabled {
                #if RELEASE
                    Flurry.logError(context, message: "\(error)", error: error as NSError)
                #endif
            }
        }
    }

    func trackShareWithActivityType(activityType: String, contentName: String, contentType: AnalyticsServiceContentType, identifier: String) {
        self.applicationSettingsRepository.isAnalyticsEnabled { (analyticsEnabled) -> Void in
            if analyticsEnabled {
                #if RELEASE
                    let flurryParams = ["name": contentName, "type": contentType.description, "id": identifier]
                    Flurry.logEvent("Completed content share", withParameters: flurryParams)
                #endif
            }
        }
    }

    func trackSearchWithQuery(query: String, context: AnalyticsSearchContext) {
        self.applicationSettingsRepository.isAnalyticsEnabled { (analyticsEnabled) -> Void in
            if analyticsEnabled {
                #if RELEASE
                    let flurryParams = ["query": query, "context": context.description]
                    Flurry.logEvent("Search", withParameters: flurryParams)
                #endif
            }
        }
    }
}
