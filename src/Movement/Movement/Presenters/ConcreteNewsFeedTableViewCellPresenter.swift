import Foundation


class ConcreteNewsFeedTableViewCellPresenter: NewsFeedTableViewCellPresenter {
    private let articlePresenter: NewsFeedTableViewCellPresenter!

    init(articlePresenter: NewsFeedTableViewCellPresenter) {
        self.articlePresenter = articlePresenter
    }

    func setupTableView(tableView: UITableView) {
        self.articlePresenter.setupTableView(tableView)
    }

    func cellForTableView(tableView: UITableView, newsFeedItem: NewsFeedItem) -> UITableViewCell {
        return self.articlePresenter.cellForTableView(tableView, newsFeedItem: newsFeedItem)
    }
}
