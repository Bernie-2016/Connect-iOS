import Foundation

class ConcreteEventRSVPControllerProvider: EventRSVPControllerProvider {
    private let analyticsService: AnalyticsService
    private let theme: Theme

    init(analyticsService: AnalyticsService, theme: Theme) {
        self.analyticsService = analyticsService
        self.theme = theme
    }

    func provideControllerWithEvent(event: Event) -> EventRSVPController {
        return EventRSVPController(event: event, analyticsService: self.analyticsService, theme: self.theme)
    }
}
