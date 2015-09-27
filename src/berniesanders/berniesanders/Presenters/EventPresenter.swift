import UIKit

public class EventPresenter {
    public init() {
        
    }
    
    public func presentEvent(event: Event, cell: EventListTableViewCell) -> EventListTableViewCell {
        cell.nameLabel.text = event.name
        cell.addressLabel.text = self.presentAddressForEvent(event)
        cell.attendeesLabel.text = self.presentAttendeesForEvent(event)

        return cell
    }
    
    public func presentAddressForEvent(event: Event) -> String {
      return String(format: NSLocalizedString("Connect_eventAddressLabel", comment: ""), event.city, event.state, event.zip)
    }
    
    public func presentAttendeesForEvent(event: Event) -> String {
        if(event.attendeeCapacity == 0) {
            return String(format: NSLocalizedString("Connect_eventAttendeeWithoutCapacityLimitLabel", comment: ""), event.attendeeCount)
            
        } else {
            return String(format: NSLocalizedString("Connect_eventAttendeeLabel", comment: ""), event.attendeeCount, event.attendeeCapacity)
        }
    }
}
