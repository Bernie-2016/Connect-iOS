import Foundation
@testable import Movement

class FakeTimeIntervalFormatter: TimeIntervalFormatter {
    var lastFormattedDate: NSDate!
    var lastAbbreviatedDates: [NSDate] = []
    var lastDaysSinceDates: [NSDate] = []
    var returnsDaysSinceDate = 0

    func humanDaysSinceDate(date: NSDate) -> String {
        self.lastFormattedDate = date
        return "human date"
    }

    func abbreviatedHumanDaysSinceDate(date: NSDate) -> String {
        self.lastAbbreviatedDates.append(date)
        return "abbreviated \(date)"
    }

    func numberOfDaysSinceDate(date: NSDate) -> Int {
        self.lastDaysSinceDates.append(date)
        return self.returnsDaysSinceDate
    }
}
