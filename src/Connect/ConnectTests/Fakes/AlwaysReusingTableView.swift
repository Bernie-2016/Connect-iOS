import UIKit

class AlwaysReusingTableView: UITableView {
    var cell: UITableViewCell?

    override func dequeueReusableCellWithIdentifier(identifier: String) -> UITableViewCell? {
        if cell != nil {
            return cell
        }

        cell = super.dequeueReusableCellWithIdentifier(identifier)

        return cell
    }
}
