import UIKit

// swiftlint:disable type_name
class NewsArticleNewsFeedCollectionViewCellPresenter: NewsFeedCollectionViewCellPresenter {
// swiftlint:enable type_name
    let imageService: ImageService
    let timeIntervalFormatter: TimeIntervalFormatter

    init(imageService: ImageService, timeIntervalFormatter: TimeIntervalFormatter) {
        self.imageService = imageService
        self.timeIntervalFormatter = timeIntervalFormatter
    }

    private let kCollectionViewCellName = "NewsFeedCollectionViewCellPresenterCell"

    func setupCollectionView(collectionView: UICollectionView) {
        collectionView.registerClass(NewsArticleCollectionViewCell.self, forCellWithReuseIdentifier: kCollectionViewCellName)
    }

    func cellForCollectionView(collectionView: UICollectionView, newsFeedItem: NewsFeedItem, indexPath: NSIndexPath) -> UICollectionViewCell? {
        guard let newsArticle = newsFeedItem as? NewsArticle else { return nil }
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCollectionViewCellName, forIndexPath: indexPath) as? NewsArticleCollectionViewCell else {
            return nil
        }

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
}
