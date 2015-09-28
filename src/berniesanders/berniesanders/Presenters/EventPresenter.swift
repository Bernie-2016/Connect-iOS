import UIKit

public class EventPresenter {
    public init() {
        
    }
    
    public func presentEvent(event: Event, cell: EventListTableViewCell) -> EventListTableViewCell {
        cell.nameLabel.text = event.name
        cell.addressLabel.text = self.presentCityAddressForEvent(event)
        cell.attendeesLabel.text = self.presentAttendeesForEvent(event)

        return cell
    }
    
    public func presentAddressForEvent(event: Event) -> String {
        if(event.streetAddress != nil) {
            return String(format: NSLocalizedString("Events_eventStreetAddressLabel", comment: ""), event.streetAddress!, event.city, event.state, event.zip)
        } else {
            return self.presentCityAddressForEvent(event)
        }
    }
    
    public func presentAttendeesForEvent(event: Event) -> String {
        if(event.attendeeCapacity == 0) {
            return String(format: NSLocalizedString("Events_eventAttendeeWithoutCapacityLimitLabel", comment: ""), event.attendeeCount)
            
        } else {
            return String(format: NSLocalizedString("Events_eventAttendeeLabel", comment: ""), event.attendeeCount, event.attendeeCapacity)
        }
    }
    
    // MARK: Private
    
    public func presentCityAddressForEvent(event: Event) -> String {
      return String(format: NSLocalizedString("Events_eventAddressLabel", comment: ""), event.city, event.state, event.zip)
    }
}
