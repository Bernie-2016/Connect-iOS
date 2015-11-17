import UIKit

class ConcreteEventControllerProvider: EventControllerProvider {
    private let eventPresenter: EventPresenter
    private let eventRSVPControllerProvider: EventRSVPControllerProvider
    private let urlProvider: URLProvider
    private let urlOpener: URLOpener
    private let analyticsService: AnalyticsService
    private let theme: Theme

    init(eventPresenter: EventPresenter, eventRSVPControllerProvider: EventRSVPControllerProvider, urlProvider: URLProvider, urlOpener: URLOpener, analyticsService: AnalyticsService, theme: Theme) {
        self.eventPresenter = eventPresenter
        self.eventRSVPControllerProvider = eventRSVPControllerProvider
        self.urlProvider = urlProvider
        self.urlOpener = urlOpener
        self.analyticsService = analyticsService
        self.theme = theme
    }

    func provideInstanceWithEvent(event: Event) -> EventController {
        return EventController(event: event, eventPresenter: self.eventPresenter, eventRSVPControllerProvider: self.eventRSVPControllerProvider,
            urlProvider: self.urlProvider, urlOpener: self.urlOpener, analyticsService: self.analyticsService, theme: self.theme)
    }
}
