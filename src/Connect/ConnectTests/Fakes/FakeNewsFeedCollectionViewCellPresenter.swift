@testable import Connect

class FakeNewsFeedCellProvider: NewsFeedCellProvider {

    var lastSetupCollectionView: UICollectionView!
    func setupCollectionView(collectionView: UICollectionView) {
        lastSetupCollectionView = collectionView
    }

    var returnNil = false
    var returnedCells = [NewsArticleCollectionViewCell]()
    var receivedCollectionViews = [UICollectionView]()
    var receivedNewsFeedItems = [NewsFeedItem]()
    var receivedIndexPaths = [NSIndexPath]()
    func cellForCollectionView(collectionView: UICollectionView, newsFeedItem: NewsFeedItem, indexPath: NSIndexPath) -> UICollectionViewCell? {
        receivedCollectionViews.append(collectionView)
        receivedNewsFeedItems.append(newsFeedItem)
        receivedIndexPaths.append(indexPath)

        if returnNil == true {
            return nil
        }

        let returnedCell = NewsArticleCollectionViewCell()
        returnedCells.append(returnedCell)

        return returnedCell
    }
}
