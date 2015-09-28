import Foundation

public class ConcreteEventControllerProvider : EventControllerProvider {
    let eventPresenter: EventPresenter!
    let theme : Theme!
    
    public init(eventPresenter: EventPresenter, theme: Theme) {
        self.eventPresenter = eventPresenter
        self.theme = theme
    }
    
    public func provideInstanceWithEvent(event: Event) -> EventController {
        return EventController(event: event, eventPresenter: self.eventPresenter, theme: self.theme)
    }
}
