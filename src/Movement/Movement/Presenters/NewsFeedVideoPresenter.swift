import Foundation
import CBGPromise

class NewsFeedVideoPresenter: NewsFeedTableViewCellPresenter {
    let timeIntervalFormatter: TimeIntervalFormatter
    let urlProvider: URLProvider
    let imageService: ImageService
    let theme: Theme

    init(timeIntervalFormatter: TimeIntervalFormatter,
        urlProvider: URLProvider,
        imageService: ImageService,
        theme: Theme) {
            self.timeIntervalFormatter = timeIntervalFormatter
            self.urlProvider = urlProvider
            self.imageService = imageService
            self.theme = theme
    }

    func setupTableView(tableView: UITableView) {
        tableView.registerClass(NewsFeedVideoTableViewCell.self, forCellReuseIdentifier: "videoCell")
    }

    func cellForTableView(tableView: UITableView, newsFeedItem: NewsFeedItem, indexPath: NSIndexPath) -> UITableViewCell {
        let cell: NewsFeedVideoTableViewCell! = tableView.dequeueReusableCellWithIdentifier("videoCell") as? NewsFeedVideoTableViewCell

        guard let video: Video = newsFeedItem as? Video else { return cell }

        cell.titleLabel.text = video.title
        cell.descriptionLabel.text = video.description
        cell.dateLabel.text = timeIntervalFormatter.abbreviatedHumanDaysSinceDate(video.date)
        cell.topSpaceConstraint.constant = (indexPath.section == 0 && indexPath.row == 0 ? 0 : 9)

        let thumbnailURL = urlProvider.youtubeThumbnailURL(video.identifier)
        let imageFuture = imageService.fetchImageWithURL(thumbnailURL)
        imageFuture.then({ image in
            cell.thumbnailImageView.image = image
        })

        applyThemeToCell(cell, video: video)

        return cell
    }

    private func applyThemeToCell(cell: NewsFeedVideoTableViewCell, video: Video) {
        cell.titleLabel.font = self.theme.newsFeedTitleFont()
        cell.titleLabel.textColor = self.theme.newsFeedTitleColor()
        cell.dateLabel.font = self.theme.newsFeedDateFont()
        cell.descriptionLabel.textColor = theme.newsFeedExcerptColor()
        cell.descriptionLabel.font = theme.newsFeedExcerptFont()
        cell.overlayView.backgroundColor = theme.newsFeedVideoOverlayBackgroundColor()
        cell.dateLabel.textColor = self.theme.highlightDisclosureColor()
    }
}
