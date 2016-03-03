import UIKit

class NewsArticleCollectionViewCell: UICollectionViewCell {
    let titleLabel = UILabel.newAutoLayoutView()
    let imageView = UIImageView.newAutoLayoutView()
    var imageVisible = false

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(titleLabel)
        contentView.addSubview(imageView)

        imageView.autoPinEdgeToSuperviewEdge(.Top)
        imageView.autoPinEdgeToSuperviewEdge(.Right)
        imageView.autoPinEdgeToSuperviewEdge(.Left)
        imageView.autoSetDimension(.Height, toSize: 50)

        titleLabel.numberOfLines = 0
        titleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: imageView)
        titleLabel.autoPinEdgeToSuperviewEdge(.Right)
        titleLabel.autoPinEdgeToSuperviewEdge(.Left)
        titleLabel.autoPinEdgeToSuperviewEdge(.Bottom)

        backgroundColor = UIColor.blueColor()
    }
}
