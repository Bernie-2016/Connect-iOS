import Foundation

class ConcreteEventListTableViewCellStylist: EventListTableViewCellStylist {
    private let theme: Theme
    private let calendar = NSCalendar.currentCalendar()

    init(theme: Theme) {
        self.theme = theme
    }

    func styleCell(cell: EventListTableViewCell, event: Event) {
        self.calendar.timeZone = event.timeZone
        let isToday = self.calendar.isDateInToday(event.startDate)

        cell.dateLabel.textColor = isToday ? self.theme.eventsListDateTodayColor() : self.theme.eventsListDateColor()
        cell.distanceLabel.textColor = isToday ? self.theme.eventsListDistanceTodayColor() : self.theme.eventsListDistanceColor()
        cell.disclosureView.color = isToday ? self.theme.highlightDisclosureColor() : self.theme.defaultDisclosureColor()

        cell.nameLabel.textColor = self.theme.eventsListNameColor()
        cell.nameLabel.font = self.theme.eventsListNameFont()
        cell.distanceLabel.font = self.theme.eventsListDistanceFont()
        cell.dateLabel.font = self.theme.eventsListDateFont()
    }
}
