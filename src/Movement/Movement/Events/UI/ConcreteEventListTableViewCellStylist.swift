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
        cell.disclosureView.color = theme.defaultDisclosureColor()
        cell.nameLabel.font = theme.eventsListNameFont()
        cell.nameLabel.textColor = theme.eventsListNameColor()
        cell.dateLabel.font = theme.eventsListDateFont()
        cell.dateLabel.textColor = theme.eventsListDateColor()
        cell.backgroundColor = theme.defaultTableCellBackgroundColor()
    }
}
