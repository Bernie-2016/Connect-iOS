import Foundation
@testable import berniesanders

class FakeEventRSVPControllerProvider : EventRSVPControllerProvider {
    var lastReceivedEvent : Event!
    let returnedController = TestUtils.eventRSVPController()

    func provideControllerWithEvent(event: Event) -> EventRSVPController {
        self.lastReceivedEvent = event
        return returnedController
    }
}
