import UIKit

public class ConcreteEventControllerProvider : EventControllerProvider {
    let eventPresenter: EventPresenter!
    let urlProvider: URLProvider!
    let urlOpener: URLOpener!
    let theme : Theme!
    
    public init(eventPresenter: EventPresenter, urlProvider: URLProvider, urlOpener: URLOpener, theme: Theme) {
        self.eventPresenter = eventPresenter
        self.urlProvider = urlProvider
        self.urlOpener = urlOpener
        self.theme = theme
    }
    
    public func provideInstanceWithEvent(event: Event) -> EventController {
        return EventController(event: event, eventPresenter: self.eventPresenter, urlProvider:
            self.urlProvider, urlOpener: self.urlOpener, theme: self.theme)
    }
}
