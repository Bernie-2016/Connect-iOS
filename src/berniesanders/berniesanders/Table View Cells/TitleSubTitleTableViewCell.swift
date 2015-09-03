import UIKit
import PureLayout


public class TitleSubTitleTableViewCell : UITableViewCell {
    private(set) public var titleLabel: UILabel
    private(set) public var dateLabel: UILabel
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.titleLabel = UILabel.newAutoLayoutView()
        self.dateLabel = UILabel.newAutoLayoutView()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false
        
        self.contentView.addSubview(dateLabel)
        dateLabel.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 4)
        dateLabel.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 8)

        
        self.contentView.addSubview(titleLabel)
        titleLabel.numberOfLines = 2
        titleLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: dateLabel, withOffset: 4)
        titleLabel.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Left, ofView: dateLabel, withOffset: 0)
        titleLabel.autoSetDimension(.Width, toSize: self.bounds.width - 85, relation: .LessThanOrEqual)
    }
}