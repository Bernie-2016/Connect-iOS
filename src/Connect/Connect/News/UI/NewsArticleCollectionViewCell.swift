import UIKit

class NewsArticleCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView.newAutoLayoutView()
    let titleLabel = UILabel.newAutoLayoutView()
    let dateLabel = UILabel.newAutoLayoutView()

    var titleToImageConstaint: NSLayoutConstraint!
    var titleToTopConstraint: NSLayoutConstraint!

    var imageVisible: Bool {
        get {
            return !self.imageView.hidden
        }
        set {
            self.imageView.hidden = !newValue
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

        backgroundColor = UIColor.greenColor()

        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true

        titleLabel.backgroundColor = UIColor.magentaColor()
        dateLabel.backgroundColor = UIColor.blueColor()

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)

        let borderPadding: CGFloat = 10
        let verticalPadding: CGFloat = 13

        imageView.autoPinEdgeToSuperviewEdge(.Top)
        imageView.autoPinEdgeToSuperviewEdge(.Right)
        imageView.autoPinEdgeToSuperviewEdge(.Left)

        titleLabel.numberOfLines = 4

        NSLayoutConstraint.autoSetPriority(999, forConstraints: { () -> Void in
            self.titleToImageConstaint = self.titleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.imageView, withOffset: verticalPadding)
        })

        NSLayoutConstraint.autoSetPriority(100, forConstraints: { () -> Void in
            self.titleToTopConstraint = self.titleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: verticalPadding)
        })

        titleLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: borderPadding)
        titleLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: borderPadding)

        dateLabel.numberOfLines = 1
        dateLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel)
        dateLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: borderPadding)
        dateLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: borderPadding)
        dateLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: verticalPadding)

//        backgroundColor = UIColor.blueColor()
    }
}
