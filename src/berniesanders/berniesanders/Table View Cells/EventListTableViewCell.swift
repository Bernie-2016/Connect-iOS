import UIKit

public class EventListTableViewCell : UITableViewCell {
    public let nameLabel = UILabel.newAutoLayoutView()
    public let addressLabel = UILabel.newAutoLayoutView()
    public let attendeesLabel = UILabel.newAutoLayoutView()
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.accessoryType = UITableViewCellAccessoryType.None
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false
        
        self.contentView.addSubview(nameLabel)
        nameLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 4)
        nameLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 8)
        
        self.contentView.addSubview(addressLabel)
        addressLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: nameLabel, withOffset: 4)
        addressLabel.autoPinEdge(.Left, toEdge: .Left, ofView: nameLabel, withOffset: 0)
        addressLabel.autoSetDimension(.Width, toSize: self.bounds.width - 85, relation: .LessThanOrEqual)
        
        self.contentView.addSubview(attendeesLabel)
        attendeesLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: addressLabel, withOffset: 4)
        attendeesLabel.autoPinEdge(.Left, toEdge: .Left, ofView: addressLabel, withOffset: 0)
        attendeesLabel.autoSetDimension(.Width, toSize: self.bounds.width - 85, relation: .LessThanOrEqual)
    }

}
