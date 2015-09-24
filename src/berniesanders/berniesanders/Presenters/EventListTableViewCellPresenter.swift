import UIKit

public class EventListTableViewCellPresenter {
    public init() {
        
    }
    
    public func presentEvent(event: Event, cell: EventListTableViewCell) -> EventListTableViewCell {
        cell.nameLabel.text = event.name
        cell.addressLabel.text = String(format: NSLocalizedString("Connect_eventAddressLabel", comment: ""), event.city, event.state, event.zip)
        if(event.attendeeCapacity == 0) {
            cell.attendeesLabel.text = String(format: NSLocalizedString("Connect_eventAttendeeWithoutCapacityLimitLabel", comment: ""), event.attendeeCount)
            
        } else {
            cell.attendeesLabel.text = String(format: NSLocalizedString("Connect_eventAttendeeLabel", comment: ""), event.attendeeCount, event.attendeeCapacity)
        }

        return cell
    }
}
