import UIKit

protocol NewsFeedCollectionViewCellPresenter {
    func setupCollectionView(collectionView: UICollectionView)
    func cellForCollectionView(collectionView: UICollectionView, newsFeedItem: NewsFeedItem, indexPath: NSIndexPath) -> UICollectionViewCell?
}

class StockNewsFeedCollectionViewCellPresenter: NewsFeedCollectionViewCellPresenter {
    let childPresenters: [NewsFeedCollectionViewCellPresenter]

    init(childPresenters: [NewsFeedCollectionViewCellPresenter]) {
        self.childPresenters = childPresenters
    }

    func setupCollectionView(collectionView: UICollectionView) {
        for childPresenter in childPresenters {
            childPresenter.setupCollectionView(collectionView)
        }
    }

    func cellForCollectionView(collectionView: UICollectionView, newsFeedItem: NewsFeedItem, indexPath: NSIndexPath) -> UICollectionViewCell? {
        for childPresenter in childPresenters {
            if let cell = childPresenter.cellForCollectionView(collectionView, newsFeedItem: newsFeedItem, indexPath: indexPath) {
                return cell
            }
        }

        return nil
    }
}
