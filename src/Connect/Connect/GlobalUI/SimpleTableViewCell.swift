import UIKit
import PureLayout


class SimpleTableViewCell: UITableViewCell {
    let titleLabel = UILabel.newAutoLayoutView()
    let disclosureIndicatorView = DisclosureIndicatorView()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        separatorInset = UIEdgeInsetsMake(0, 20, 0, 0)
        layoutMargins = UIEdgeInsetsZero
        preservesSuperviewLayoutMargins = false

        contentView.addSubview(titleLabel)
        contentView.addSubview(disclosureIndicatorView)

        titleLabel.numberOfLines = 3
        titleLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        titleLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 45)
        titleLabel.autoAlignAxisToSuperviewAxis(.Horizontal)

        disclosureIndicatorView.autoAlignAxis(.Horizontal, toSameAxisOfView: titleLabel)
        disclosureIndicatorView.autoPinEdgeToSuperviewEdge(.Right)
        disclosureIndicatorView.autoSetDimension(.Height, toSize: 14)
        disclosureIndicatorView.autoSetDimension(.Width, toSize: 20)
    }
}
