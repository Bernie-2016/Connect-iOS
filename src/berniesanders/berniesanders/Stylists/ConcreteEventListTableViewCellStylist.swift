import Foundation

class ConcreteEventListTableViewCellStylist: EventListTableViewCellStylist {
    private let theme: Theme

    init(theme: Theme) {
        self.theme = theme
    }

    func styleCell(cell: EventListTableViewCell) {
        cell.nameLabel.textColor = self.theme.eventsListNameColor()
        cell.nameLabel.font = self.theme.eventsListNameFont()
        cell.distanceLabel.textColor = self.theme.eventsListDistanceColor()
        cell.distanceLabel.font = self.theme.eventsListDistanceFont()
        cell.dateLabel.textColor = self.theme.eventsListDateColor()
        cell.dateLabel.font = self.theme.eventsListDateFont()
    }
}
