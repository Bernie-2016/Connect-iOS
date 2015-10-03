import Foundation

public class ConcreteEventRSVPControllerProvider : EventRSVPControllerProvider {
    let analyticsService: AnalyticsService!
    let theme: Theme!
    
    public init(analyticsService: AnalyticsService, theme: Theme) {
        self.analyticsService = analyticsService
        self.theme = theme
    }
    
    public func provideControllerWithEvent(event: Event) -> EventRSVPController {
        return EventRSVPController(event: event, analyticsService: self.analyticsService, theme: self.theme)
    }
}
