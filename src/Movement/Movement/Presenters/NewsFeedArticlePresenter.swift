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

    func cellForTableView(tableView: UITableView, newsFeedItem: NewsFeedItem) -> UITableViewCell {
        let cell: NewsArticleTableViewCell! = tableView.dequeueReusableCellWithIdentifier("regularCell") as? NewsArticleTableViewCell

        let newsArticle: NewsArticle! = newsFeedItem as? NewsArticle
        if newsArticle == nil { return cell }

        cell.titleLabel.text = newsArticle.title
        cell.excerptLabel.text = newsArticle.excerpt
        cell.dateLabel.text = self.timeIntervalFormatter.abbreviatedHumanDaysSinceDate(newsArticle.date)

        self.applyThemeToNewsCell(cell, newsArticle: newsArticle)

        cell.newsImageView.image = nil

        guard let imageURL = newsArticle.imageURL else {
            cell.newsImageVisible = false
            return cell
        }

        cell.newsImageVisible = true
        let imageFuture = imageService.fetchImageWithURL(imageURL)
        imageFuture.then { image in
            cell.newsImageView.image = image
        }

        return cell
    }

    private func applyThemeToNewsCell(cell: NewsArticleTableViewCell, newsArticle: NewsArticle) {
        cell.titleLabel.font = self.theme.newsFeedTitleFont()
        cell.titleLabel.textColor = self.theme.newsFeedTitleColor()
        cell.excerptLabel.font = self.theme.newsFeedExcerptFont()
        cell.excerptLabel.textColor = self.theme.newsFeedExcerptColor()
        cell.dateLabel.font = self.theme.newsFeedDateFont()
        cell.dateLabel.textColor = self.theme.highlightDisclosureColor()
    }
}
