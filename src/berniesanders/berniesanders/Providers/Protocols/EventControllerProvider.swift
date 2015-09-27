import Foundation


public protocol EventControllerProvider {
    func provideInstanceWithEvent(event: Event) -> EventController;
}