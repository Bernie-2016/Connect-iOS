import UIKit

@testable import Movement

class FakeNewsFeedTableViewCellPresenter: NewsFeedTableViewCellPresenter {
    var returnedCells = [NewsArticleTableViewCell]()
    var receivedTableViews = [UITableView]()
    var receivedNewsFeedItems =  [NewsFeedItem]()

    func cellForTableView(tableView: UITableView, newsFeedItem: NewsFeedItem) -> UITableViewCell {
        self.receivedTableViews.append(tableView)
        self.receivedNewsFeedItems.append(newsFeedItem)
        let returnedCell = NewsArticleTableViewCell()
        self.returnedCells.append(returnedCell)
        return returnedCell
    }

    var lastSetupTableView: UITableView!
    func setupTableView(tableView: UITableView) {
        self.lastSetupTableView = tableView
    }
}

