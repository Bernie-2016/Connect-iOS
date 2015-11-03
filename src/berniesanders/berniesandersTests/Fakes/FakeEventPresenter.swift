import Foundation
import CoreLocation

@testable import berniesanders

class FakeEventPresenter : EventPresenter {
    var lastReceivedEvent: Event?
    var lastSearchCentroid: CLLocation?
    var lastReceivedCell: EventListTableViewCell?
    var lastEventWithPresentedAddress : Event!
    var lastEventWithPresentedAttendees : Event!
    var lastEventWithPresentedDate : Event!

    override func presentAddressForEvent(event: Event) -> String {
        self.lastEventWithPresentedAddress = event
        return "SOME COOL ADDRESS!"
    }

    override func presentAttendeesForEvent(event: Event) -> String {
        self.lastEventWithPresentedAttendees = event
        return "LOTS OF PEOPLE!"
    }

    override func presentEvent(event: Event, searchCentroid: CLLocation, cell: EventListTableViewCell) -> EventListTableViewCell {
        lastReceivedEvent = event
        lastSearchCentroid = searchCentroid
        lastReceivedCell = cell
        return cell
    }

    override func presentDateForEvent(event: Event) -> String {
        lastEventWithPresentedDate = event
        return "PRESENTED DATE!"
    }
}
