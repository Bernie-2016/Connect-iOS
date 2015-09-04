import UIKit
import PureLayout


public class IssueTableViewCell : UITableViewCell {
    public let titleLabel: UILabel
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.titleLabel = UILabel.newAutoLayoutView()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.accessoryType = UITableViewCellAccessoryType.None
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false
        
        self.contentView.addSubview(titleLabel)
        titleLabel.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 8)
        titleLabel.autoAlignAxisToSuperviewAxis(.Horizontal)
    }
}