import Foundation

class ConcreteEventListTableViewCellStylist: EventListTableViewCellStylist {
    private let dateProvider: DateProvider
    private let theme: Theme
    private let calendar = NSCalendar.currentCalendar()

    init(dateProvider: DateProvider, theme: Theme) {
        self.dateProvider = dateProvider
        self.theme = theme
    }

    func styleCell(cell: EventListTableViewCell, event: Event) {
        let today = self.dateProvider.now()
        let todayComponents = self.calendar.components(NSCalendarUnit([.Year, .Month, .Day]), fromDate: today)
        let normalizedToday = self.calendar.dateFromComponents(todayComponents)!

        self.calendar.timeZone = event.timeZone
        let eventDateComponents = self.calendar.components(NSCalendarUnit([.Year, .Month, .Day]), fromDate: event.startDate)
        self.calendar.timeZone = NSTimeZone.localTimeZone()
        let normalizedEventDate = self.calendar.dateFromComponents(eventDateComponents)!

        let isToday = self.calendar.isDate(normalizedEventDate, inSameDayAsDate: normalizedToday)

        cell.dateLabel.textColor = isToday ? self.theme.eventsListDateTodayColor() : self.theme.eventsListDateColor()
        cell.distanceLabel.textColor = isToday ? self.theme.eventsListDistanceTodayColor() : self.theme.eventsListDistanceColor()
        cell.disclosureView.color = isToday ? self.theme.highlightDisclosureColor() : self.theme.defaultDisclosureColor()

        cell.nameLabel.textColor = self.theme.eventsListNameColor()
        cell.nameLabel.font = self.theme.eventsListNameFont()
        cell.distanceLabel.font = self.theme.eventsListDistanceFont()
        cell.dateLabel.font = self.theme.eventsListDateFont()
    }
}
