import UIKit

protocol ActionsTableViewCellPresenter {
    func presentActionAlertTableViewCell(actionAlert: ActionAlert, tableView: UITableView) -> UITableViewCell
}

class StockActionsTableViewCellPresenter: ActionsTableViewCellPresenter {
    let theme: Theme

    init(theme: Theme) {
        self.theme = theme
    }

    func presentActionAlertTableViewCell(actionAlert: ActionAlert, tableView: UITableView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("actionAlertCell") as? ActionAlertTableViewCell else { return UITableViewCell() }

        cell.backgroundColor = theme.defaultTableCellBackgroundColor()
        cell.titleLabel.text = actionAlert.title
        cell.titleLabel.textColor = theme.actionsTitleTextColor()
        cell.titleLabel.font = theme.actionsTitleFont()
        cell.disclosureView.color = theme.defaultDisclosureColor()

        return cell
    }
}
