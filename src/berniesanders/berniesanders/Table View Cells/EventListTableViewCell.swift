import UIKit

public class EventListTableViewCell: UITableViewCell {
    public let nameLabel = UILabel.newAutoLayoutView()
    public let addressLabel = UILabel.newAutoLayoutView()
    public let attendeesLabel = UILabel.newAutoLayoutView()

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.accessoryType = .DisclosureIndicator
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false

        self.contentView.addSubview(nameLabel)
        nameLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 16)
        nameLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 8)
        nameLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 8)

        self.contentView.addSubview(addressLabel)
        addressLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: nameLabel, withOffset: 4)
        addressLabel.autoPinEdge(.Left, toEdge: .Left, ofView: nameLabel, withOffset: 0)
        addressLabel.autoPinEdge(.Right, toEdge: .Right, ofView: nameLabel, withOffset: 0)

        self.contentView.addSubview(attendeesLabel)
        attendeesLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: addressLabel, withOffset: 4)
        attendeesLabel.autoPinEdge(.Left, toEdge: .Left, ofView: addressLabel, withOffset: 0)
        attendeesLabel.autoPinEdge(.Right, toEdge: .Right, ofView: attendeesLabel, withOffset: 0)
    }

}
