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
        
        titleLabel.text = "hello"
        self.contentView.addSubview(titleLabel)
        titleLabel.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 10)
        titleLabel.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 20)

        dateLabel.text = "there"
        self.contentView.addSubview(dateLabel)
        dateLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: titleLabel, withOffset: 0)
        dateLabel.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Left, ofView: titleLabel, withOffset: 0)
    }
}