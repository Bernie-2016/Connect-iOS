import UIKit

class NewsArticleCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView.newAutoLayoutView()
    let dateLabel = UILabel.newAutoLayoutView()
    let titleLabel = UILabel.newAutoLayoutView()
    var imageVisible = false

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(titleLabel)

        imageView.autoPinEdgeToSuperviewEdge(.Top)
        imageView.autoPinEdgeToSuperviewEdge(.Right)
        imageView.autoPinEdgeToSuperviewEdge(.Left)
        imageView.autoSetDimension(.Height, toSize: 50)

        dateLabel.numberOfLines = 1
        dateLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: imageView)
        dateLabel.autoPinEdgeToSuperviewEdge(.Right)
        dateLabel.autoPinEdgeToSuperviewEdge(.Left)

        titleLabel.numberOfLines = 0
        titleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: dateLabel)
        titleLabel.autoPinEdgeToSuperviewEdge(.Right)
        titleLabel.autoPinEdgeToSuperviewEdge(.Left)
        titleLabel.autoPinEdgeToSuperviewEdge(.Bottom)

        backgroundColor = UIColor.blueColor()
    }
}
