import Foundation
import DateTools

class ConcreteTimeIntervalFormatter: TimeIntervalFormatter {
    private let dateProvider: DateProvider
    private let currentCalendar = NSCalendar.currentCalendar()

    init(dateProvider: DateProvider) {
        self.dateProvider = dateProvider
    }

    func humanDaysSinceDate(date: NSDate) -> String {
        return date.timeAgoSinceNow()
    }

    func numberOfDaysSinceDate(date: NSDate) -> Int {
        return self.currentCalendar.components(.Day, fromDate: date, toDate: self.dateProvider.now(), options: []).day
    }
}
