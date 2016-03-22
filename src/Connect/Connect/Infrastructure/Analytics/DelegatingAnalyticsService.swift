class DelegatingAnalyticsService: AnalyticsService {
    let delegates: [AnalyticsService]

    init(delegates: [AnalyticsService]) {
        self.delegates = delegates
    }

    func trackShareWithActivityType(activityType: String, contentName: String, contentType: AnalyticsServiceContentType, identifier: String) {
        for delegate in delegates {
            delegate.trackShareWithActivityType(activityType, contentName: contentName, contentType: contentType, identifier: identifier)
        }
    }

    func trackSearchWithQuery(query: String, context: AnalyticsSearchContext) {
        for delegate in delegates {
            delegate.trackSearchWithQuery(query, context: context)
        }
    }

    func trackPageViewWithName(name: String, customAttributes: [NSObject : AnyObject]?) {
        for delegate in delegates {
            delegate.trackPageViewWithName(name, customAttributes: customAttributes)
        }
    }

    func trackError(error: ErrorType, context: String) {
        for delegate in delegates {
            delegate.trackError(error, context: context)
        }
    }

    func trackCustomEventWithName(name: String, customAttributes: [NSObject : AnyObject]?) {
        for delegate in delegates {
            delegate.trackCustomEventWithName(name, customAttributes: customAttributes)
        }
    }

    func trackContentViewWithName(name: String, type: AnalyticsServiceContentType, identifier: String) {
        for delegate in delegates {
            delegate.trackContentViewWithName(name, type: type, identifier: identifier)
        }
    }

    func trackBackButtonTapOnScreen(screen: String, customAttributes: [NSObject : AnyObject]?) {
        for delegate in delegates {
            delegate.trackBackButtonTapOnScreen(screen, customAttributes: customAttributes)
        }
    }
}
