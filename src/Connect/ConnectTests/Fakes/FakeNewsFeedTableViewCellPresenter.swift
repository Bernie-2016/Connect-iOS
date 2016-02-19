import UIKit

@testable import Connect

class FakeNewsFeedTableViewCellPresenter: NewsFeedTableViewCellPresenter {
    var returnedCells = [NewsArticleTableViewCell]()
    var receivedTableViews = [UITableView]()
    var receivedNewsFeedItems =  [NewsFeedItem]()
    var receivedIndexPaths = [NSIndexPath]()

    func cellForTableView(tableView: UITableView, newsFeedItem: NewsFeedItem, indexPath: NSIndexPath) -> UITableViewCell {
        self.receivedTableViews.append(tableView)
        self.receivedNewsFeedItems.append(newsFeedItem)
        self.receivedIndexPaths.append(indexPath)

        let returnedCell = NewsArticleTableViewCell()
        self.returnedCells.append(returnedCell)

        return returnedCell
    }

    var lastSetupTableView: UITableView!
    func setupTableView(tableView: UITableView) {
        self.lastSetupTableView = tableView
    }
}

