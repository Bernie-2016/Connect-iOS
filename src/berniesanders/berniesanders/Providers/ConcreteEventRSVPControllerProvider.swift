import Foundation

public class ConcreteEventRSVPControllerProvider : EventRSVPControllerProvider {
    let theme: Theme!
    
    public init(theme: Theme) {
        self.theme = theme
    }
    
    public func provideControllerWithEvent(event: Event) -> EventRSVPController {
        return EventRSVPController(event: event, theme: self.theme)
    }
}
