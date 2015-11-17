import Foundation

class EventSectionHeaderPresenter {
    private let currentWeekDateFormatter: NSDateFormatter
    private let nonCurrentWeekDateFormatter: NSDateFormatter
    private let dateProvider: DateProvider
    private let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!

    init(currentWeekDateFormatter: NSDateFormatter,
        nonCurrentWeekDateFormatter: NSDateFormatter,
        dateProvider: DateProvider) {
            self.currentWeekDateFormatter = currentWeekDateFormatter
            self.nonCurrentWeekDateFormatter = nonCurrentWeekDateFormatter
            self.dateProvider = dateProvider
    }

    func headerForDate(date: NSDate) -> String {
        let today = self.dateProvider.now()

        let weekFromToday = self.calendar.dateByAddingUnit(.Day, value: 7, toDate: today, options: NSCalendarOptions(rawValue: 0))!
        let weekFromTodayComponents = self.calendar.components(NSCalendarUnit([.Day, .Month, .Year]), fromDate: weekFromToday)
        let normalizedWeekFromToday = self.calendar.dateFromComponents(weekFromTodayComponents)!

        if calendar.isDate(date, inSameDayAsDate: today) {
            return NSLocalizedString("Events_todayHeader", comment: "")
        }

        if date.compare(normalizedWeekFromToday) == NSComparisonResult.OrderedAscending {
            return self.currentWeekDateFormatter.stringFromDate(date).uppercaseString
        } else {
            return self.nonCurrentWeekDateFormatter.stringFromDate(date).uppercaseString
        }
    }
}
