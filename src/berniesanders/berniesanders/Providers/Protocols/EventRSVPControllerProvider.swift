import Foundation

public protocol EventRSVPControllerProvider {
    func provideControllerWithEvent(event: Event) -> EventRSVPController
}
