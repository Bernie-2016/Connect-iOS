import UIKit

@testable import Movement

class FakeNewsFeedTableViewCellPresenter: NewsFeedTableViewCellPresenter {
    let returnedErrorCell = UITableViewCell()
    var lastReceivedErrorTableView: UITableView!

    func errorCellForTableView(tableView: UITableView) -> UITableViewCell {
        self.lastReceivedErrorTableView = tableView
        return self.returnedErrorCell
    }

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
}

