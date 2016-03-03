import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView.newAutoLayoutView()
    let playIconImageView = UIImageView.newAutoLayoutView()
    let titleLabel = UILabel.newAutoLayoutView()
    let dateLabel = UILabel.newAutoLayoutView()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        playIconImageView.image = UIImage(named: "Play")

        layer.shadowOffset = CGSize.zero
        layer.shadowOpacity = 1
        layer.shadowRadius = 2
        layer.shadowPath = UIBezierPath(rect: bounds).CGPath

        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true

        contentView.addSubview(imageView)
        contentView.addSubview(playIconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)

        let borderPadding: CGFloat = 10
        let verticalPadding: CGFloat = 13

        imageView.autoPinEdgeToSuperviewEdge(.Top)
        imageView.autoPinEdgeToSuperviewEdge(.Right)
        imageView.autoPinEdgeToSuperviewEdge(.Left)

        playIconImageView.autoPinEdge(.Left, toEdge: .Left, ofView: imageView, withOffset: 10)
        playIconImageView.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: imageView, withOffset: -10)

        titleLabel.numberOfLines = 4
        titleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: imageView, withOffset: verticalPadding)
        titleLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: borderPadding)
        titleLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: borderPadding)

        dateLabel.numberOfLines = 1
        dateLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 16)
        dateLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: borderPadding)
        dateLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: borderPadding)
        dateLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: borderPadding)
    }
}
