import UIKit

class EventListTableViewCell: UITableViewCell {
    let nameLabel = UILabel.newAutoLayoutView()
    let distanceLabel = UILabel.newAutoLayoutView()
    let disclosureView = DisclosureIndicatorView.newAutoLayoutView()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.accessoryType = .None
        self.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        self.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        self.preservesSuperviewLayoutMargins = false

        nameLabel.numberOfLines = 2

        distanceLabel.textAlignment = .Right

        disclosureView.backgroundColor = UIColor.whiteColor()
        disclosureView.color = UIColor.blackColor()

        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(disclosureView)
        self.contentView.addSubview(distanceLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        nameLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 16)
        nameLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        nameLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 75)
        nameLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 16)

        distanceLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 16)
        distanceLabel.autoPinEdge(.Left, toEdge: .Right, ofView: nameLabel)
        distanceLabel.autoPinEdge(.Right, toEdge: .Left, ofView: disclosureView, withOffset: -5)

        disclosureView.autoPinEdge(.Top, toEdge: .Top, ofView: nameLabel)
        disclosureView.autoPinEdgeToSuperviewEdge(.Right)
        disclosureView.autoSetDimension(.Height, toSize: 20)
        disclosureView.autoSetDimension(.Width, toSize: 20)
    }
}
