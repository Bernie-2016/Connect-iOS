import UIKit
import PureLayout

class NewsArticleTableViewCell: UITableViewCell {
    let titleLabel = UILabel.newAutoLayoutView()
    let excerptLabel = UILabel.newAutoLayoutView()
    let newsImageView = UIImageView.newAutoLayoutView()

    private var excerptRightEdge: NSLayoutConstraint?
    private let rightMarginWithoutImage: CGFloat
    private let rightMarginWithImage: CGFloat

    var newsImageVisible: Bool {
        get {
            return !self.newsImageView.hidden
        }
        set {
            self.newsImageView.hidden = !newValue
            self.excerptRightEdge!.constant = newValue ? rightMarginWithImage : rightMarginWithoutImage
            self.layoutSubviews()
        }
    }


    private let containerView = UIView.newAutoLayoutView()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        let defaultHorizontalMargin: CGFloat = 15
        rightMarginWithoutImage = -defaultHorizontalMargin
        rightMarginWithImage = -(108 + defaultHorizontalMargin + defaultHorizontalMargin)

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .None

        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(excerptLabel)
        containerView.addSubview(newsImageView)

        self.backgroundColor = UIColor.clearColor()

        containerView.backgroundColor = UIColor.whiteColor()

        accessoryType = .None
        separatorInset = UIEdgeInsetsZero
        layoutMargins = UIEdgeInsetsZero
        preservesSuperviewLayoutMargins = false

        titleLabel.numberOfLines = 3

        excerptLabel.numberOfLines = 3
        excerptLabel.adjustsFontSizeToFitWidth = false
        excerptLabel.lineBreakMode = .ByTruncatingTail

        newsImageView.backgroundColor = UIColor.grayColor()

        setupConstraints()
    }

    private func setupConstraints() {
        let defaultVerticalMargin: CGFloat = 16
        let defaultHorizontalMargin: CGFloat = 15

        containerView.autoPinEdgeToSuperviewEdge(.Top, withInset: 9)
        containerView.autoPinEdgeToSuperviewEdge(.Left)
        containerView.autoPinEdgeToSuperviewEdge(.Right)
        containerView.autoPinEdgeToSuperviewEdge(.Bottom)

        titleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: defaultVerticalMargin)
        titleLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        titleLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 50)

        newsImageView.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 5)
        newsImageView.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin)
        newsImageView.autoSetDimension(.Width, toSize: 108)
        newsImageView.autoSetDimension(.Height, toSize: 60)
        newsImageView.clipsToBounds = true
        newsImageView.contentMode = .ScaleAspectFill

        excerptLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 5)
        excerptLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        self.excerptRightEdge = excerptLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin + 108 + defaultHorizontalMargin)
        excerptLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: defaultVerticalMargin)
    }
}
