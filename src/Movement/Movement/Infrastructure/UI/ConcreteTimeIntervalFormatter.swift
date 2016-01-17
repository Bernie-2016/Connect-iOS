import Foundation

class ConcreteTimeIntervalFormatter: TimeIntervalFormatter {
    private let dateProvider: DateProvider
    private let currentCalendar = NSCalendar.currentCalendar()

    init(dateProvider: DateProvider) {
        self.dateProvider = dateProvider
    }

    func humanDaysSinceDate(date: NSDate) -> String {
        let numberOfDays = self.numberOfDaysSinceDate(date)

        if numberOfDays == 0 {
            return NSLocalizedString("TimeInterval_today", comment: "")
        } else {
            return NSString.localizedStringWithFormat(NSLocalizedString("TimeInterval_daysAgo %d", comment: ""),  numberOfDays) as String
        }
    }

    func numberOfDaysSinceDate(date: NSDate) -> Int {
        return self.currentCalendar.components(.Day, fromDate: date, toDate: self.dateProvider.now(), options: []).day
    }
}
