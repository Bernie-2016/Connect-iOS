import UIKit
import PureLayout

class ActionTableViewCell: UITableViewCell {
    let titleLabel = UILabel.newAutoLayoutView()
    let subTitleLabel = UILabel.newAutoLayoutView()
    let iconImageView = UIImageView.newAutoLayoutView()
    let disclosureView = DisclosureIndicatorView.newAutoLayoutView()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .None

        contentView.addSubview(titleLabel)
        contentView.addSubview(disclosureView)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(iconImageView)

        self.backgroundColor = UIColor.clearColor()

        accessoryType = .None
        separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        layoutMargins = UIEdgeInsetsZero
        preservesSuperviewLayoutMargins = false

        titleLabel.numberOfLines = 3

        setupConstraints()
    }

    // MARK: Private

    private func setupConstraints() {
        titleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 20)
        titleLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 56)
        titleLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 45)

        iconImageView.autoAlignAxis(.Horizontal, toSameAxisOfView: titleLabel)
        iconImageView.autoPinEdgeToSuperviewEdge(.Left, withInset: 22)


        subTitleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel)
        subTitleLabel.autoPinEdge(.Left, toEdge: .Left, ofView: titleLabel)
        subTitleLabel.autoPinEdge(.Right, toEdge: .Right, ofView: titleLabel)
        subTitleLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 20)

        disclosureView.autoAlignAxis(.Horizontal, toSameAxisOfView: titleLabel)
        disclosureView.autoPinEdgeToSuperviewEdge(.Right)
        disclosureView.autoSetDimension(.Height, toSize: 14)
        disclosureView.autoSetDimension(.Width, toSize: 20)

    }
}
