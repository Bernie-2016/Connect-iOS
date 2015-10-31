import Foundation

class ConcreteTimeIntervalFormatter: TimeIntervalFormatter {
    let dateProvider: DateProvider

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

    func abbreviatedHumanDaysSinceDate(date: NSDate) -> String {
        let numberOfDays = self.numberOfDaysSinceDate(date)

        if numberOfDays == 0 {
            return NSLocalizedString("TimeInterval_now", comment: "")
        } else {
            return NSString.localizedStringWithFormat(NSLocalizedString("TimeInterval_abbreviatedDaysAgo %d", comment: ""),  numberOfDays) as String
        }

    }

    // MARK: Private

    private func numberOfDaysSinceDate(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self.dateProvider.now(), options: []).day
    }
}
