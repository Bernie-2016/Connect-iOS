import UIKit

class NewsArticleCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView.newAutoLayoutView()
    let titleLabel = UILabel.newAutoLayoutView()
    let excerptLabel = UILabel.newAutoLayoutView()
    let dateLabel = UILabel.newAutoLayoutView()

    var titleToImageConstaint: NSLayoutConstraint!
    var titleToTopConstraint: NSLayoutConstraint!

    var imageVisible: Bool {
        get {
            return !self.imageView.hidden
        }
        set {
            self.imageView.hidden = !newValue
            self.excerptLabel.hidden = newValue
            self.titleToTopConstraint.priority = newValue ? 100 : 999
            self.titleToImageConstaint.priority = newValue ? 999 : 100
            self.layoutSubviews()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true

        layer.shadowOffset = CGSize.zero
        layer.shadowOpacity = 1
        layer.shadowRadius = 2
        layer.shadowPath = UIBezierPath(rect: bounds).CGPath

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(excerptLabel)
        contentView.addSubview(dateLabel)

        let borderPadding: CGFloat = 10
        let verticalPadding: CGFloat = 13

        imageView.autoPinEdgeToSuperviewEdge(.Top)
        imageView.autoPinEdgeToSuperviewEdge(.Right)
        imageView.autoPinEdgeToSuperviewEdge(.Left)

        NSLayoutConstraint.autoSetPriority(999, forConstraints: { () -> Void in
            self.titleToImageConstaint = self.titleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.imageView, withOffset: verticalPadding)
        })

        NSLayoutConstraint.autoSetPriority(100, forConstraints: { () -> Void in
            self.titleToTopConstraint = self.titleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: verticalPadding)
        })

        titleLabel.numberOfLines = 5
        titleLabel.setContentCompressionResistancePriority(1000, forAxis: .Vertical)
        titleLabel.setContentHuggingPriority(1000, forAxis: .Vertical)
        titleLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: borderPadding)
        titleLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: borderPadding)

        excerptLabel.numberOfLines = 0
        excerptLabel.setContentCompressionResistancePriority(1, forAxis: .Vertical)
        excerptLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 3)
        excerptLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: borderPadding)
        excerptLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: borderPadding)

        dateLabel.numberOfLines = 1
        dateLabel.setContentCompressionResistancePriority(1000, forAxis: .Vertical)
        dateLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 16, relation: .GreaterThanOrEqual)
        dateLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: excerptLabel, withOffset: 16, relation: .GreaterThanOrEqual)
        dateLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: borderPadding)
        dateLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: borderPadding)
        dateLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: borderPadding)
    }
}
