import UIKit
import PureLayout

class ActionAlertTableViewCell: UITableViewCell {
    let titleLabel = UILabel.newAutoLayoutView()
    let disclosureView = DisclosureIndicatorView.newAutoLayoutView()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .None

        contentView.addSubview(titleLabel)
        contentView.addSubview(disclosureView)

        backgroundColor = UIColor.clearColor()

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
        titleLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        titleLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 45)
        titleLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 20)

        disclosureView.autoAlignAxis(.Horizontal, toSameAxisOfView: titleLabel)
        disclosureView.autoPinEdgeToSuperviewEdge(.Right)
        disclosureView.autoSetDimension(.Height, toSize: 14)
        disclosureView.autoSetDimension(.Width, toSize: 20)
    }
}
