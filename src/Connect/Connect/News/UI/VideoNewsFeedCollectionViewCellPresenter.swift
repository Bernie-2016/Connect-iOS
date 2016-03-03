import UIKit

class VideoNewsFeedCollectionViewCellPresenter: NewsFeedCollectionViewCellPresenter {
    private let kCollectionViewCellName = "NewsFeedCollectionViewCellPresenterCell"

    private let imageService: ImageService
    private let urlProvider: URLProvider
    private let timeIntervalFormatter: TimeIntervalFormatter

    init(imageService: ImageService, urlProvider: URLProvider, timeIntervalFormatter: TimeIntervalFormatter) {
        self.imageService = imageService
        self.urlProvider = urlProvider
        self.timeIntervalFormatter = timeIntervalFormatter
    }

    func setupCollectionView(collectionView: UICollectionView) {
        collectionView.registerClass(NewsArticleCollectionViewCell.self, forCellWithReuseIdentifier: kCollectionViewCellName)
    }

    func cellForCollectionView(collectionView: UICollectionView, newsFeedItem: NewsFeedItem, indexPath: NSIndexPath) -> UICollectionViewCell? {
        guard let video = newsFeedItem as? Video else { return nil }
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCollectionViewCellName, forIndexPath: indexPath) as? NewsArticleCollectionViewCell else {
            return nil
        }

        cell.titleLabel.text = video.title
        cell.dateLabel.text = timeIntervalFormatter.humanDaysSinceDate(video.date)

        cell.imageVisible = true

        let thumbnailURL = urlProvider.youtubeThumbnailURL(video.identifier)

        if cell.tag != thumbnailURL.hashValue {
            cell.imageView.image = nil
        }

        cell.tag = thumbnailURL.hashValue

        let imageFuture = imageService.fetchImageWithURL(thumbnailURL)
        imageFuture.then({ image in
            if cell.tag == thumbnailURL.hashValue {
                UIView.transitionWithView(cell.imageView, duration: 0.3, options: .TransitionCrossDissolve, animations: {
                    cell.imageView.image = image
                    }, completion: nil)
            }
        })


        return cell
    }
}
