import Foundation


protocol EventControllerProvider {
    func provideInstanceWithEvent(event: Event) -> EventController;
}
