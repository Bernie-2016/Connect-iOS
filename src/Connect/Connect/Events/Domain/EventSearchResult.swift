import Foundation
import CoreLocation

class EventSearchResult {
    let events: Array<Event>

    init(events: Array<Event>) {
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

        return eventsForDay.sort({ (eventA, eventB) -> Bool in
            eventTimeZoneCalendar.timeZone = eventA.timeZone
            let eventAComponents = eventTimeZoneCalendar.components(NSCalendarUnit([.Hour, .Minute]), fromDate: eventA.startDate)

            eventTimeZoneCalendar.timeZone = eventB.timeZone
            let eventBComponents = eventTimeZoneCalendar.components(NSCalendarUnit([.Hour, .Minute]), fromDate: eventB.startDate)

            if eventAComponents.hour < eventBComponents.hour {
                return true
            } else if eventAComponents.hour == eventBComponents.hour {
                if eventAComponents.minute < eventBComponents.minute {
                    return true
                } else if eventAComponents.minute == eventBComponents.minute {
                    return true
                }
            }

            return false
        })
    }
}
