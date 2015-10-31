protocol TimeIntervalFormatter {
    func humanDaysSinceDate(date: NSDate) -> String
    func abbreviatedHumanDaysSinceDate(date: NSDate) -> String
    func numberOfDaysSinceDate(date: NSDate) -> Int
}
