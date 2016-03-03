import UIKit

class AlwaysReusingCollectionView: UICollectionView {
    var cell: UICollectionViewCell?

    override func dequeueReusableCellWithReuseIdentifier(identifier: String, forIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if cell != nil { return cell! }

        cell = super.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath)
        return cell!
    }
}
