import UIKit

// swiftlint:disable type_name
class NewsArticleNewsFeedCollectionViewCellPresenter: NewsFeedCollectionViewCellPresenter {
// swiftlint:enable type_name
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

        return cell
    }
}
