import UIKit

class EventListTableViewCell: UITableViewCell {
    let nameLabel = UILabel.newAutoLayoutView()
    let dateLabel = UILabel.newAutoLayoutView()
    let disclosureView = DisclosureIndicatorView.newAutoLayoutView()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        accessoryType = .None
        separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        preservesSuperviewLayoutMargins = false

        nameLabel.numberOfLines = 2

        dateLabel.textAlignment = .Right

        contentView.addSubview(nameLabel)
        contentView.addSubview(disclosureView)
        contentView.addSubview(dateLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        let defaultHorizontalMargin: CGFloat = 19

        nameLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 15)
        nameLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        nameLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 100)
        nameLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 15)

        dateLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: disclosureView)
        dateLabel.autoPinEdge(.Left, toEdge: .Right, ofView: nameLabel)
        dateLabel.autoPinEdge(.Right, toEdge: .Left, ofView: disclosureView, withOffset: -7)

        disclosureView.autoPinEdge(.Top, toEdge: .Top, ofView: nameLabel, withOffset: 2)
        disclosureView.autoPinEdgeToSuperviewEdge(.Right)
        disclosureView.autoSetDimension(.Height, toSize: 14)
        disclosureView.autoSetDimension(.Width, toSize: 20)
    }
}
