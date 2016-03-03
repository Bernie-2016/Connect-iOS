import UIKit

class VideoNewsFeedCollectionViewCellPresenter: NewsFeedCollectionViewCellPresenter {
    private let kCollectionViewCellName = "VideoCollectionViewCellPresenterCell"

    private let imageService: ImageService
    private let urlProvider: URLProvider
    private let timeIntervalFormatter: TimeIntervalFormatter
    private let theme: Theme

    init(imageService: ImageService, urlProvider: URLProvider, timeIntervalFormatter: TimeIntervalFormatter, theme: Theme) {
        self.imageService = imageService
        self.urlProvider = urlProvider
        self.timeIntervalFormatter = timeIntervalFormatter
        self.theme = theme
    }

    func setupCollectionView(collectionView: UICollectionView) {
        collectionView.registerClass(VideoCollectionViewCell.self, forCellWithReuseIdentifier: kCollectionViewCellName)
    }

    func cellForCollectionView(collectionView: UICollectionView, newsFeedItem: NewsFeedItem, indexPath: NSIndexPath) -> UICollectionViewCell? {
        guard let video = newsFeedItem as? Video else { return nil }
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCollectionViewCellName, forIndexPath: indexPath) as? VideoCollectionViewCell else {
            return nil
        }
        
        applyThemeToVideCell(cell)

        cell.titleLabel.text = video.title
        cell.dateLabel.text = timeIntervalFormatter.humanDaysSinceDate(video.date)

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
    
      private func applyThemeToVideCell(cell: VideoCollectionViewCell) {
           cell.backgroundColor = theme.contentBackgroundColor()
               cell.titleLabel.font = theme.newsFeedTitleFont()
               cell.titleLabel.textColor = theme.newsFeedTitleColor()
               cell.dateLabel.font = theme.newsFeedDateFont()
               cell.dateLabel.textColor = theme.newsFeedDateColor()
          }
}
