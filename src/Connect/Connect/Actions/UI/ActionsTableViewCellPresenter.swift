import UIKit

protocol ActionsTableViewCellPresenter {
    func presentActionAlertTableViewCell(actionAlert: ActionAlert, tableView: UITableView) -> UITableViewCell
    func presentActionTableViewCell(actionAlerts: [ActionAlert], indexPath: NSIndexPath, tableView: UITableView) -> UITableViewCell
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

    func presentActionTableViewCell(actionAlerts: [ActionAlert], indexPath: NSIndexPath, tableView: UITableView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("actionCell") as? ActionTableViewCell else { return UITableViewCell() }

        var titleKey: String!
        var subTitleKey: String!
        let donationSection = actionAlerts.count == 0 ? 0 : 1

        if indexPath.section == donationSection {
            titleKey = indexPath.row == 0 ? "Actions_donateTitle" : "Actions_shareDonateTitle"
            subTitleKey = indexPath.row == 0 ? "Actions_donateSubTitle" : "Actions_shareDonateSubTitle"
        } else {
            titleKey = "Actions_hostEventTitle"
            subTitleKey = "Actions_hostEventSubTitle"

            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGRectGetWidth(tableView.bounds))
        }

        cell.backgroundColor = theme.defaultTableCellBackgroundColor()
        cell.titleLabel.text = NSLocalizedString(titleKey, comment: "")
        cell.subTitleLabel.text = NSLocalizedString(subTitleKey, comment: "")

        cell.titleLabel.font = theme.actionsTitleFont()
        cell.titleLabel.textColor = theme.actionsTitleTextColor()
        cell.subTitleLabel.font = theme.actionsSubTitleFont()
        cell.subTitleLabel.textColor = theme.actionsSubTitleTextColor()
        cell.disclosureView.color = theme.defaultDisclosureColor()

        return cell
    }
}
