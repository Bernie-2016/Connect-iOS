import UIKit

class NewsArticleCollectionViewCell: UICollectionViewCell {
    let titleLabel = UILabel.newAutoLayoutView()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(titleLabel)

        titleLabel.numberOfLines = 0
        titleLabel.autoPinEdgesToSuperviewEdges()
        backgroundColor = UIColor.blueColor()
    }
}
