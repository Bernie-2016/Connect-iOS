import UIKit
import PureLayout


class IssueTableViewCell: UITableViewCell {
    let titleLabel: UILabel

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        titleLabel = UILabel.newAutoLayoutView()

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        accessoryType = .DisclosureIndicator
        separatorInset = UIEdgeInsetsZero
        layoutMargins = UIEdgeInsetsZero
        preservesSuperviewLayoutMargins = false

        contentView.addSubview(titleLabel)
        titleLabel.numberOfLines = 3
        titleLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 8)
        titleLabel.autoPinEdgeToSuperviewEdge(.Right)
        titleLabel.autoAlignAxisToSuperviewAxis(.Horizontal)
    }
}
