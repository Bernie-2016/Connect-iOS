import UIKit

protocol NewsFeedTableViewCellPresenter {
    func setupTableView(tableView: UITableView)
    func cellForTableView(tableView: UITableView, newsFeedItem: NewsFeedItem) -> UITableViewCell
}
