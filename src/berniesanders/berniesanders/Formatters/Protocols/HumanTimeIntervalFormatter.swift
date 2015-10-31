protocol HumanTimeIntervalFormatter {
    func humanDaysSinceDate(date: NSDate) -> String
    func abbreviatedHumanDaysSinceDate(date: NSDate) -> String
}
