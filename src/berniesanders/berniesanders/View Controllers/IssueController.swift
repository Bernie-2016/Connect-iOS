import UIKit

public class IssueController : UIViewController {
    public init(issue: Issue) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
