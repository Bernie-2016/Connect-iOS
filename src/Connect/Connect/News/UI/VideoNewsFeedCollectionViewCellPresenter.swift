import UIKit

class VideoNewsFeedCollectionViewCellPresenter: NewsFeedCollectionViewCellPresenter {
    private let kCollectionViewCellName = "NewsFeedCollectionViewCellPresenterCell"

    func setupCollectionView(collectionView: UICollectionView) {
        collectionView.registerClass(NewsArticleCollectionViewCell.self, forCellWithReuseIdentifier: kCollectionViewCellName)
    }

    func cellForCollectionView(collectionView: UICollectionView, newsFeedItem: NewsFeedItem, indexPath: NSIndexPath) -> UICollectionViewCell? {
        guard let video = newsFeedItem as? Video else { return nil }
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCollectionViewCellName, forIndexPath: indexPath) as? NewsArticleCollectionViewCell else {
            return nil
        }

        cell.titleLabel.text = video.title

        return cell
    }
}
