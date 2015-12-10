import Foundation
import BrightFutures

class NewsFeedVideoPresenter: NewsFeedTableViewCellPresenter {
    func setupTableView(tableView: UITableView) {
        tableView.registerClass(NewsFeedVideoTableViewCell.self, forCellReuseIdentifier: "videoCell")
    }

    func cellForTableView(tableView: UITableView, newsFeedItem: NewsFeedItem) -> UITableViewCell {
        let cell: NewsFeedVideoTableViewCell! = tableView.dequeueReusableCellWithIdentifier("videoCell") as? NewsFeedVideoTableViewCell

        let video: Video! = newsFeedItem as? Video
        if video == nil { return cell }

        cell.titleLabel.text = video.title

        return cell
    }
}
