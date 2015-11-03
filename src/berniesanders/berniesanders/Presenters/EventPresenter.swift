import UIKit
import CoreLocation

class EventPresenter {
    private let dateFormatter: NSDateFormatter

    init(dateFormatter: NSDateFormatter) {
        self.dateFormatter = dateFormatter
    }

    func presentEvent(event: Event, searchCentroid: CLLocation, cell: EventListTableViewCell) -> EventListTableViewCell {
        cell.nameLabel.text = event.name

        let distanceToEvent = searchCentroid.distanceFromLocation(event.location)
        let lengthFormatter = NSLengthFormatter()
        lengthFormatter.numberFormatter.maximumFractionDigits = 1
        cell.distanceLabel.text = lengthFormatter.stringFromValue(distanceToEvent / 1609.34, unit: .Mile) // :(

        return cell
    }

    func presentAddressForEvent(event: Event) -> String {
        if event.streetAddress != nil {
            return String(format: NSLocalizedString("Events_eventStreetAddressLabel", comment: ""), event.streetAddress!, event.city, event.state, event.zip)
        } else {
            return self.presentCityAddressForEvent(event)
        }
    }

    func presentAttendeesForEvent(event: Event) -> String {
        if event.attendeeCapacity == 0 {
            return String(format: NSLocalizedString("Events_eventAttendeeWithoutCapacityLimitLabel", comment: ""), event.attendeeCount)

        } else {
            return String(format: NSLocalizedString("Events_eventAttendeeLabel", comment: ""), event.attendeeCount, event.attendeeCapacity)
        }
    }

    func presentDateForEvent(event: Event) -> String {
        self.dateFormatter.timeZone = event.timeZone
        return self.dateFormatter.stringFromDate(event.startDate)
    }

    // MARK: Private

    func presentCityAddressForEvent(event: Event) -> String {
      return String(format: NSLocalizedString("Events_eventAddressLabel", comment: ""), event.city, event.state, event.zip)
    }
}
