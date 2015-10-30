import Foundation

class ConcreteHumanTimeIntervalFormatter: HumanTimeIntervalFormatter {
    let dateProvider: DateProvider

    init(dateProvider: DateProvider) {
        self.dateProvider = dateProvider
    }

    func humanDaysSinceDate(date: NSDate) -> String {
        let numberOfDays = NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self.dateProvider.now(), options: []).day

        if numberOfDays == 0 {
            return NSLocalizedString("TimeInterval_today", comment: "")
        } else {
            return NSString.localizedStringWithFormat(NSLocalizedString("TimeInterval_daysAgo %d", comment: ""),  numberOfDays) as String
        }
    }
}
