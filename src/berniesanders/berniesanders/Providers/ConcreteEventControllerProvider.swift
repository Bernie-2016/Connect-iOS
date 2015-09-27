import Foundation

public class ConcreteEventControllerProvider : EventControllerProvider {
    let eventPresenter: EventPresenter!
    let dateFormatter : NSDateFormatter!
    let theme : Theme!
    
    public init(eventPresenter: EventPresenter, dateFormatter: NSDateFormatter, theme: Theme) {
        self.eventPresenter = eventPresenter
        self.dateFormatter = dateFormatter
        self.theme = theme
    }
    
    public func provideInstanceWithEvent(event: Event) -> EventController {
        return EventController(event: event, eventPresenter: self.eventPresenter, dateFormatter: self.dateFormatter, theme: self.theme)
    }
}
