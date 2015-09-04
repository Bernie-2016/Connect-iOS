import UIKit

public class TableHeaderView : UITableViewHeaderFooterView {
    public let titleLabel : UILabel = UILabel()
    
    override init(frame:CGRect) {
        super.init(frame:frame)
    }

    init(title: String) {
        super.init(reuseIdentifier: "TableHeaderView") // TODO: move this somewhere else.

        self.titleLabel.text = title
        self.addSubview(self.titleLabel)
        self.titleLabel.autoCenterInSuperview()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
