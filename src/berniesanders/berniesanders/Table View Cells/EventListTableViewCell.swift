import UIKit

class EventListTableViewCell: UITableViewCell {
    let nameLabel = UILabel.newAutoLayoutView()
    let distanceLabel = UILabel.newAutoLayoutView()
    let dateLabel = UILabel.newAutoLayoutView()
    let disclosureView = DisclosureIndicatorView.newAutoLayoutView()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        accessoryType = .None
        separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        preservesSuperviewLayoutMargins = false

        nameLabel.numberOfLines = 2

        distanceLabel.textAlignment = .Right
        dateLabel.textAlignment = .Right

        disclosureView.backgroundColor = UIColor.whiteColor()
        disclosureView.color = UIColor.blackColor()

        contentView.addSubview(nameLabel)
        contentView.addSubview(disclosureView)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(dateLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        nameLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 15)
        nameLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        nameLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 100)
        nameLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 15)

        dateLabel.autoPinEdge(.Top, toEdge: .Top, ofView: disclosureView, withOffset: -7)
        dateLabel.autoPinEdge(.Left, toEdge: .Right, ofView: nameLabel)
        dateLabel.autoPinEdge(.Right, toEdge: .Left, ofView: disclosureView, withOffset: -7)

        distanceLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: dateLabel)
        distanceLabel.autoPinEdge(.Left, toEdge: .Right, ofView: nameLabel)
        distanceLabel.autoPinEdge(.Right, toEdge: .Left, ofView: disclosureView, withOffset: -7)

        disclosureView.autoAlignAxis(.Horizontal, toSameAxisOfView: nameLabel)
        disclosureView.autoPinEdgeToSuperviewEdge(.Right)
        disclosureView.autoSetDimension(.Height, toSize: 14)
        disclosureView.autoSetDimension(.Width, toSize: 20)
    }
}
