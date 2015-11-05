import Foundation
import CoreLocation

class EventSearchResult {
    let searchCentroid: CLLocation
    let events: Array<Event>

    init(searchCentroid: CLLocation, events: Array<Event>) {
        self.searchCentroid = searchCentroid
        self.events = events
    }

    func uniqueDaysInLocalTimeZone() -> [NSDate] {
        let currentCalendar = NSCalendar.currentCalendar()
        let eventTimeZoneCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let uniqueDays = NSMutableSet()

        for event in events {
            eventTimeZoneCalendar.timeZone = event.timeZone
            let dateComponents = eventTimeZoneCalendar.components(NSCalendarUnit([.Year, .Month, .Day]), fromDate: event.startDate)
            let dayDate = currentCalendar.dateFromComponents(dateComponents)!
            uniqueDays.addObject(dayDate)
        }

        let sortDescriptor = NSSortDescriptor(key: "self", ascending: true)
        guard let sortedDays = uniqueDays.sortedArrayUsingDescriptors([sortDescriptor]) as? [NSDate] else {
            return []
        }

        return sortedDays
    }

    func eventsWithDayIndex(dayIndex: Int) -> [Event] {
        let dayDate = self.uniqueDaysInLocalTimeZone()[dayIndex]

        let eventTimeZoneCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let dayComponents = eventTimeZoneCalendar.components(NSCalendarUnit([.Year, .Month, .Day]), fromDate:dayDate)

        var eventsForDay = [Event]()

        for event in events {
            eventTimeZoneCalendar.timeZone = event.timeZone
            let dayDateInEventTimeZone = eventTimeZoneCalendar.dateFromComponents(dayComponents)!

            if eventTimeZoneCalendar.isDate(event.startDate, inSameDayAsDate: dayDateInEventTimeZone) {
                eventsForDay.append(event)
            }
        }

        return eventsForDay
    }
}
