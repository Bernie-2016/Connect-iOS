import UIKit
import PureLayout


class NewsItemTableViewCell: UITableViewCell {
    let titleLabel = UILabel.newAutoLayoutView()
    let excerptLabel = UILabel.newAutoLayoutView()
    let dateLabel = UILabel.newAutoLayoutView()

    private let disclosureLabel = UILabel.newAutoLayoutView()
    private let containerView = UIView.newAutoLayoutView()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .None

        self.contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(disclosureLabel)
        containerView.addSubview(excerptLabel)

        self.backgroundColor = UIColor.clearColor()

        containerView.backgroundColor = UIColor.whiteColor()

        self.accessoryType = .None
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false

        titleLabel.numberOfLines = 3

        dateLabel.textAlignment = .Right

        disclosureLabel.text = "〉"
        disclosureLabel.font = UIFont.systemFontOfSize(13)

        excerptLabel.numberOfLines = 4
        excerptLabel.adjustsFontSizeToFitWidth = false
        excerptLabel.lineBreakMode = .ByTruncatingTail

        setupConstraints()
    }

    private func setupConstraints() {
        containerView.autoPinEdgeToSuperviewEdge(.Top, withInset: 11)
        containerView.autoPinEdgeToSuperviewEdge(.Left)
        containerView.autoPinEdgeToSuperviewEdge(.Right)
        containerView.autoPinEdgeToSuperviewEdge(.Bottom)

        titleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 20)
        titleLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        titleLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 50)

        dateLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 25)
        dateLabel.autoPinEdge(.Left, toEdge: .Right, ofView: titleLabel, withOffset: 5)
        dateLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 20)

        disclosureLabel.autoPinEdge(.Top, toEdge: .Top, ofView: dateLabel, withOffset: 0)
        disclosureLabel.autoPinEdge(.Left, toEdge: .Right, ofView: dateLabel, withOffset: 5)

        excerptLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 5)
        excerptLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        excerptLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 20)
        excerptLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 11)
    }
}
