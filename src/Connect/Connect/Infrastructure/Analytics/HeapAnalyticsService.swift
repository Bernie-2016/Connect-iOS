import UIKit

class HeapAnalyticsService: AnalyticsService {
    private let applicationSettingsRepository: ApplicationSettingsRepository

    init(applicationSettingsRepository: ApplicationSettingsRepository, apiKeyProvider: APIKeyProvider) {
        self.applicationSettingsRepository = applicationSettingsRepository
        #if RELEASE
            Heap.setAppId(apiKeyProvider.heapAppID())
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

    func trackContentViewWithName(name: String, type: AnalyticsServiceContentType, identifier: String) {
        let heapParams = [ "name": name, "type": type.description, "id": identifier]
        trackCustomEventWithName("Content View", customAttributes: heapParams)
    }

    func trackCustomEventWithName(name: String, customAttributes: [NSObject : AnyObject]?) {
        applicationSettingsRepository.isAnalyticsEnabled { enabled in
            if enabled {
                #if RELEASE
                    Heap.track(name, withProperties: customAttributes)
                #endif
            }
        }
    }

    func trackError(error: ErrorType, context: String) {
        let heapParams = [ "context": context, "error": String(error) ]
        trackCustomEventWithName("Error", customAttributes: heapParams)
    }

    func trackPageViewWithName(name: String, customAttributes: [NSObject : AnyObject]?) {
        var attributes = ["pageName": name]

        if customAttributes != nil {
            for (key, value) in customAttributes! {
                guard let keyAsString = key as? String else { continue }
                attributes[keyAsString] = value as? String
            }
        }

        trackCustomEventWithName("Page View", customAttributes: attributes)
    }

    func trackSearchWithQuery(query: String, context: AnalyticsSearchContext) {
        let heapParams = ["query": query, "context": context.description]
        trackCustomEventWithName("Search", customAttributes: heapParams)
    }

    func trackShareWithActivityType(activityType: String, contentName: String, contentType: AnalyticsServiceContentType, identifier: String) {
        let heapParams = ["name": contentName, "type": contentType.description, "id": identifier]
        trackCustomEventWithName("Completed content share", customAttributes: heapParams)
    }
}
