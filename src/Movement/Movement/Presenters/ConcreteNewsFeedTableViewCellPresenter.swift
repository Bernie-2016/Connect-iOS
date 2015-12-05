import Foundation


class ConcreteNewsFeedTableViewCellPresenter: NewsFeedTableViewCellPresenter {
    private let articlePresenter: NewsFeedTableViewCellPresenter!
    private let theme: Theme!

    init(articlePresenter: NewsFeedTableViewCellPresenter, theme: Theme) {
        self.articlePresenter = articlePresenter
        self.theme = theme
    }

    func cellForTableView(tableView: UITableView, newsFeedItem: NewsFeedItem) -> UITableViewCell {
        return self.articlePresenter.cellForTableView(tableView, newsFeedItem: newsFeedItem)
    }


    func errorCellForTableView(tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("errorCell")!
        cell.textLabel!.text = NSLocalizedString("NewsFeed_errorText", comment: "")
        cell.textLabel!.font = self.theme.newsFeedTitleFont()
        cell.textLabel!.textColor = self.theme.newsFeedTitleColor()
        return cell
    }
}
