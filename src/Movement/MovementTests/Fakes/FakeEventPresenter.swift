import Foundation
import CoreLocation

@testable import Movement

class FakeEventPresenter : EventPresenter {
    var lastReceivedEvent: Event?
    var lastSearchCentroid: CLLocation?
    var lastReceivedCell: EventListTableViewCell?
    var lastEventWithPresentedAddress : Event!
    var lastEventWithPresentedRSVPText : Event!
    var lastEventWithPresentedDate : Event!
    var lastEventWithPresentedDateTime : Event!

    override func presentAddressForEvent(event: Event) -> String {
        self.lastEventWithPresentedAddress = event
        return "SOME COOL ADDRESS!"
    }

    override func presentRSVPButtonTextForEvent(event: Event) -> String {
        self.lastEventWithPresentedRSVPText = event
        return "LOTS OF PEOPLE!"
    }

    override func presentEventListCell(event: Event, searchCentroid: CLLocation, cell: EventListTableViewCell) -> EventListTableViewCell {
        lastReceivedEvent = event
        lastSearchCentroid = searchCentroid
        lastReceivedCell = cell
        return cell
    }

    override func presentTimeForEvent(event: Event) -> String {
        lastEventWithPresentedDate = event
        return "PRESENTED DATE!"
    }

    override func presentDateTimeForEvent(event: Event) -> String {
        lastEventWithPresentedDateTime = event
        return "PRESENTED DATETIME!"
    }
}
