import Foundation

protocol EventRSVPControllerProvider {
    func provideControllerWithEvent(event: Event) -> EventRSVPController
}
