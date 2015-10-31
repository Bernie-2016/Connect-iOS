import Foundation
@testable import berniesanders

class FakeTimeIntervalFormatter: TimeIntervalFormatter {
    var lastFormattedDate: NSDate!
    var lastAbbreviatedDates: [NSDate] = []

    func humanDaysSinceDate(date: NSDate) -> String {
        self.lastFormattedDate = date
        return "human date"
    }

    func abbreviatedHumanDaysSinceDate(date: NSDate) -> String {
        self.lastAbbreviatedDates.append(date)
        return "abbreviated \(date)"
    }
}
