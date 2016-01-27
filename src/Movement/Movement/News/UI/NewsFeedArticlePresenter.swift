import Foundation
import CBGPromise

class NewsFeedArticlePresenter: NewsFeedTableViewCellPresenter {
    private let timeIntervalFormatter: TimeIntervalFormatter
    private let imageService: ImageService
    private let theme: Theme

    init(timeIntervalFormatter: TimeIntervalFormatter, imageService: ImageService, theme: Theme) {
        self.timeIntervalFormatter = timeIntervalFormatter
        self.imageService = imageService
        self.theme = theme
    }

    func setupTableView(tableView: UITableView) {
        tableView.registerClass(NewsArticleTableViewCell.self, forCellReuseIdentifier: "regularCell")
    }

    func cellForTableView(tableView: UITableView, newsFeedItem: NewsFeedItem, indexPath: NSIndexPath) -> UITableViewCell {
        let cell: NewsArticleTableViewCell! = tableView.dequeueReusableCellWithIdentifier("regularCell") as? NewsArticleTableViewCell
        self.applyThemeToNewsCell(cell)

        let newsArticle: NewsArticle! = newsFeedItem as? NewsArticle
        if newsArticle == nil { return cell }

        cell.titleLabel.text = newsArticle.title
        let articlePublishedToday = timeIntervalFormatter.numberOfDaysSinceDate(newsArticle.date) == 0

        if articlePublishedToday {
            let nowText = NSLocalizedString("Now", comment: "")
            let attributedString = NSMutableAttributedString(string: "\(nowText) | \(newsArticle.excerpt)")
            let range = NSRange(location: 0, length: nowText.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
            attributedString.addAttribute(NSForegroundColorAttributeName, value: theme.highlightDisclosureColor(), range: range)

            cell.excerptLabel.attributedText = attributedString
        } else {
            cell.excerptLabel.text = newsArticle.excerpt
        }


        cell.newsImageView.image = nil

        guard let imageURL = newsArticle.imageURL else {
            cell.newsImageVisible = false
            return cell
        }

        cell.newsImageVisible = true
        let imageFuture = imageService.fetchImageWithURL(imageURL)
        imageFuture.then { image in
            UIView.transitionWithView(cell.newsImageView, duration: 0.3, options: .TransitionCrossDissolve, animations: {
                cell.newsImageView.image = image
            }, completion: nil)
        }

        return cell
    }

    private func applyThemeToNewsCell(cell: NewsArticleTableViewCell) {
        cell.titleLabel.font = self.theme.newsFeedTitleFont()
        cell.titleLabel.textColor = self.theme.newsFeedTitleColor()
        cell.excerptLabel.font = self.theme.newsFeedExcerptFont()
        cell.excerptLabel.textColor = self.theme.newsFeedExcerptColor()

    }
}
