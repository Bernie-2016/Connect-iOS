import UIKit
import CoreLocation

class EventPresenter {
    private let sameTimeZoneDateFormatter: NSDateFormatter
    private let differentTimeZoneDateFormatter: NSDateFormatter
    private let sameTimeZoneFullDateFormatter: NSDateFormatter
    private let differentTimeZoneFullDateFormatter: NSDateFormatter


    init(sameTimeZoneDateFormatter: NSDateFormatter,
        differentTimeZoneDateFormatter: NSDateFormatter,
        sameTimeZoneFullDateFormatter: NSDateFormatter,
        differentTimeZoneFullDateFormatter: NSDateFormatter) {
            self.sameTimeZoneDateFormatter = sameTimeZoneDateFormatter
            self.differentTimeZoneDateFormatter = differentTimeZoneDateFormatter
            self.sameTimeZoneFullDateFormatter = sameTimeZoneFullDateFormatter
            self.differentTimeZoneFullDateFormatter = differentTimeZoneFullDateFormatter
    }

    func presentEventListCell(event: Event, searchCentroid: CLLocation, cell: EventListTableViewCell) -> EventListTableViewCell {
        cell.nameLabel.text = event.name

        let distanceToEvent = searchCentroid.distanceFromLocation(event.location)
        let lengthFormatter = NSLengthFormatter()
        lengthFormatter.numberFormatter.maximumFractionDigits = 1
        cell.distanceLabel.text = lengthFormatter.stringFromValue(distanceToEvent / 1609.34, unit: .Mile) // :(
        cell.dateLabel.text = self.presentTimeForEvent(event)

        return cell
    }

    func presentAddressForEvent(event: Event) -> String {
        if event.streetAddress != nil {
            return String(format: NSLocalizedString("Events_eventStreetAddressLabel", comment: ""), event.streetAddress!, event.city, event.state, event.zip)
        } else {
            return self.presentCityAddressForEvent(event)
        }
    }

    func presentRSVPButtonTextForEvent(event: Event) -> String {
        if event.attendeeCapacity == 0 {
            return String(format: NSLocalizedString("Events_eventRSVPWithoutCapacityButtonText", comment: ""), event.attendeeCount)

        } else {
            return String(format: NSLocalizedString("Events_eventRSVPButtonText", comment: ""), event.attendeeCount, event.attendeeCapacity)
        }
    }

    func presentDateTimeForEvent(event: Event) -> String {
        if eventIsInLocalTimeZone(event) {
            self.sameTimeZoneFullDateFormatter.timeZone = event.timeZone
            return self.sameTimeZoneFullDateFormatter.stringFromDate(event.startDate)
        } else {
            self.differentTimeZoneFullDateFormatter.timeZone = event.timeZone
            return self.differentTimeZoneFullDateFormatter.stringFromDate(event.startDate)
        }
    }

    func presentTimeForEvent(event: Event) -> String {
        if eventIsInLocalTimeZone(event) {
            self.sameTimeZoneDateFormatter.timeZone = event.timeZone
            return self.sameTimeZoneDateFormatter.stringFromDate(event.startDate)
        } else {
            self.differentTimeZoneDateFormatter.timeZone = event.timeZone
            return self.differentTimeZoneDateFormatter.stringFromDate(event.startDate)
        }
    }

    // MARK: Private

    func presentCityAddressForEvent(event: Event) -> String {
        return String(format: NSLocalizedString("Events_eventAddressLabel", comment: ""), event.city, event.state, event.zip)
    }

    func eventIsInLocalTimeZone(event: Event) -> Bool {
        let localTimeZone = NSTimeZone.localTimeZone()
        return localTimeZone == event.timeZone
    }
}
