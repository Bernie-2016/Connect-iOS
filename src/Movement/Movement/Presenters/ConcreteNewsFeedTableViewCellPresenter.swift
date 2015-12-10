import Foundation


class ConcreteNewsFeedTableViewCellPresenter: NewsFeedTableViewCellPresenter {
    private let articlePresenter: NewsFeedTableViewCellPresenter!
    private let videoPresenter: NewsFeedTableViewCellPresenter!

    init(articlePresenter: NewsFeedTableViewCellPresenter, videoPresenter: NewsFeedTableViewCellPresenter) {
        self.articlePresenter = articlePresenter
        self.videoPresenter = videoPresenter
    }

    func setupTableView(tableView: UITableView) {
        self.articlePresenter.setupTableView(tableView)
        self.videoPresenter.setupTableView(tableView)
    }

    func cellForTableView(tableView: UITableView, newsFeedItem: NewsFeedItem) -> UITableViewCell {
        if newsFeedItem is Video {
            return self.videoPresenter.cellForTableView(tableView, newsFeedItem: newsFeedItem)
        } else {
            return self.articlePresenter.cellForTableView(tableView, newsFeedItem: newsFeedItem)
        }
    }
}
