import UIKit

class NewsFeedArticleCellProvider: NewsFeedCellProvider {
    let imageService: ImageService
    let timeIntervalFormatter: TimeIntervalFormatter
    let theme: Theme

    init(imageService: ImageService, timeIntervalFormatter: TimeIntervalFormatter, theme: Theme) {
        self.imageService = imageService
        self.timeIntervalFormatter = timeIntervalFormatter
        self.theme = theme
    }

    private let kCollectionViewCellName = "NewsFeedCellProviderCell"

    func setupCollectionView(collectionView: UICollectionView) {
        collectionView.registerClass(NewsArticleCollectionViewCell.self, forCellWithReuseIdentifier: kCollectionViewCellName)
    }

    func cellForCollectionView(collectionView: UICollectionView, newsFeedItem: NewsFeedItem, indexPath: NSIndexPath) -> UICollectionViewCell? {
        guard let newsArticle = newsFeedItem as? NewsArticle else { return nil }
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCollectionViewCellName, forIndexPath: indexPath) as? NewsArticleCollectionViewCell else {
            return nil
        }

        applyThemeToNewsCell(cell)

        cell.titleLabel.text = newsArticle.title
        cell.excerptLabel.text = newsArticle.excerpt
        cell.dateLabel.text = timeIntervalFormatter.humanDaysSinceDate(newsArticle.date)

        guard let imageURL = newsArticle.imageURL else {
            cell.imageVisible = false
            cell.imageView.image = nil
            cell.tag = 0
            return cell
        }

        cell.imageVisible = true

        if cell.tag != imageURL.hashValue {
            cell.imageView.image = nil
        }

        cell.tag = imageURL.hashValue

        let imageFuture = imageService.fetchImageWithURL(imageURL)
        imageFuture.then { image in
            if cell.tag == imageURL.hashValue {
                UIView.transitionWithView(cell.imageView, duration: 0.3, options: .TransitionCrossDissolve, animations: {
                    cell.imageView.image = image
                    }, completion: nil)
            }
        }

        return cell
    }

    private func applyThemeToNewsCell(cell: NewsArticleCollectionViewCell) {
        cell.backgroundColor = theme.contentBackgroundColor()
        cell.titleLabel.font = theme.newsFeedTitleFont()
        cell.titleLabel.textColor = theme.newsFeedTitleColor()
        cell.excerptLabel.font = theme.newsFeedExcerptFont()
        cell.excerptLabel.textColor = theme.newsFeedExcerptColor()
        cell.dateLabel.font = theme.newsFeedDateFont()
        cell.dateLabel.textColor = theme.newsFeedDateColor()
    }
}
