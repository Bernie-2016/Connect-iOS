import Foundation
@testable import berniesanders

class FakeHumanTimeIntervalFormatter: HumanTimeIntervalFormatter {
    var lastFormattedDate: NSDate!

    func humanDaysSinceDate(date: NSDate) -> String {
        self.lastFormattedDate = date
        return "human date"
    }
}
