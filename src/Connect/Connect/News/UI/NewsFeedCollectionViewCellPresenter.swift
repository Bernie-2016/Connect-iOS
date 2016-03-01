import UIKit

protocol NewsFeedCollectionViewCellPresenter {
    func setupCollectionView(collectionView: UICollectionView)
    func cellForCollectionView(collectionView: UICollectionView, newsFeedItem: NewsFeedItem, indexPath: NSIndexPath) -> UICollectionViewCell
}

class StockNewsFeedCollectionViewCellPresenter: NewsFeedCollectionViewCellPresenter {
    func setupCollectionView(collectionView: UICollectionView) {
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }

    func cellForCollectionView(collectionView: UICollectionView, newsFeedItem: NewsFeedItem, indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.redColor()
        return cell
    }
}
