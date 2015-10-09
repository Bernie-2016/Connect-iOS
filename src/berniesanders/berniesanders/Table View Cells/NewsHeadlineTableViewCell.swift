import UIKit
import PureLayout


public class NewsHeadlineTableViewCell: UITableViewCell {
    public let titleLabel: UILabel
    public let headlineImageView: UIImageView
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.titleLabel = UILabel.newAutoLayoutView()
        self.headlineImageView = UIImageView.newAutoLayoutView()
        self.headlineImageView.contentMode = .ScaleAspectFit
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .None
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false
        self.clipsToBounds = true
        
        self.addSubview(self.headlineImageView)
        self.addSubview(self.titleLabel)
        
        self.headlineImageView.autoPinEdgesToSuperviewEdges()
        
        self.titleLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: 0)
        self.titleLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 0)
        self.titleLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 4)
        
        self.titleLabel.numberOfLines = 2
        self.titleLabel.textAlignment = .Center
    }
}