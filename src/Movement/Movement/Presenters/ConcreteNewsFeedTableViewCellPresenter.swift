import Foundation

class ConcreteNewsFeedTableViewCellPresenter: NewsFeedTableViewCellPresenter {
    private let timeIntervalFormatter: TimeIntervalFormatter
    private let imageRepository: ImageRepository
    private let theme: Theme

    init(timeIntervalFormatter: TimeIntervalFormatter, imageRepository: ImageRepository, theme: Theme) {
        self.timeIntervalFormatter = timeIntervalFormatter
        self.imageRepository = imageRepository
        self.theme = theme
    }

    func cellForTableView(tableView: UITableView, newsFeedItem: NewsFeedItem) -> UITableViewCell {
        var cell: NewsArticleTableViewCell! = tableView.dequeueReusableCellWithIdentifier("regularCell") as? NewsArticleTableViewCell
        if cell == nil { cell = NewsArticleTableViewCell() }

        let newsArticle: NewsArticle! = newsFeedItem as? NewsArticle
        if newsArticle == nil { return cell }

        cell.titleLabel.text = newsArticle.title
        cell.excerptLabel.text = newsArticle.excerpt
        cell.dateLabel.text = self.timeIntervalFormatter.abbreviatedHumanDaysSinceDate(newsArticle.date)

        self.applyThemeToNewsCell(cell, newsArticle: newsArticle)

        cell.newsImageView.image = nil

        if newsArticle.imageURL == nil {
            cell.newsImageVisible = false
        } else {
            cell.newsImageVisible = true
            imageRepository.fetchImageWithURL(newsArticle.imageURL!).then({ (image) -> AnyObject? in
                cell.newsImageView.image = image as? UIImage
                return image
                }) { (error) -> AnyObject? in
                    return error
            }
        }

        return cell
    }

    func errorCellForTableView(tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("errorCell")!
        cell.textLabel!.text = NSLocalizedString("NewsFeed_errorText", comment: "")
        cell.textLabel!.font = self.theme.newsFeedTitleFont()
        cell.textLabel!.textColor = self.theme.newsFeedTitleColor()
        return cell
    }

    private func applyThemeToNewsCell(cell: NewsArticleTableViewCell, newsArticle: NewsArticle) {
        cell.titleLabel.font = self.theme.newsFeedTitleFont()
        cell.titleLabel.textColor = self.theme.newsFeedTitleColor()
        cell.excerptLabel.font = self.theme.newsFeedExcerptFont()
        cell.excerptLabel.textColor = self.theme.newsFeedExcerptColor()
        cell.dateLabel.font = self.theme.newsFeedDateFont()

        let disclosureColor: UIColor
        if self.timeIntervalFormatter.numberOfDaysSinceDate(newsArticle.date) == 0 {
            disclosureColor = self.theme.highlightDisclosureColor()
        } else {
            disclosureColor =  self.theme.defaultDisclosureColor()
        }

        cell.dateLabel.textColor = disclosureColor
        cell.disclosureView.color = disclosureColor
    }
}
