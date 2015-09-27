import Foundation

public class ConcreteEventControllerProvider : EventControllerProvider {
    var dateFormatter : NSDateFormatter!
    var theme : Theme!
    
    public init(dateFormatter: NSDateFormatter, theme: Theme) {
        self.dateFormatter = dateFormatter
        self.theme = theme
    }
    
    public func provideInstanceWithEvent(event: Event) -> EventController {
        return EventController(event: event, dateFormatter: self.dateFormatter, theme: self.theme)
    }
}
