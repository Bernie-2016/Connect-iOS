import UIKit

public class ConcreteEventControllerProvider : EventControllerProvider {
    let eventPresenter: EventPresenter!
    let eventRSVPControllerProvider: EventRSVPControllerProvider!
    let urlProvider: URLProvider!
    let urlOpener: URLOpener!
    let theme : Theme!
    
    public init(eventPresenter: EventPresenter, eventRSVPControllerProvider: EventRSVPControllerProvider, urlProvider: URLProvider, urlOpener: URLOpener, theme: Theme) {
        self.eventPresenter = eventPresenter
        self.eventRSVPControllerProvider = eventRSVPControllerProvider
        self.urlProvider = urlProvider
        self.urlOpener = urlOpener
        self.theme = theme
    }
    
    public func provideInstanceWithEvent(event: Event) -> EventController {
        return EventController(event: event, eventPresenter: self.eventPresenter, eventRSVPControllerProvider: self.eventRSVPControllerProvider,
            urlProvider: self.urlProvider, urlOpener: self.urlOpener, theme: self.theme)
    }
}
