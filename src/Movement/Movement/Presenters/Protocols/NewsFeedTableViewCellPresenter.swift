import UIKit

protocol NewsFeedTableViewCellPresenter {
    func cellForTableView(tableView: UITableView, newsFeedItem: NewsFeedItem) -> UITableViewCell
    func errorCellForTableView(tableView: UITableView) -> UITableViewCell
}
