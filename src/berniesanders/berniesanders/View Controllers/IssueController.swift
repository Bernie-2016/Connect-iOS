import UIKit
import PureLayout

public class IssueController : UIViewController {
    public let issue: Issue!
    public let theme: Theme!
    
    let containerView = UIView()
    let scrollView = UIScrollView()
    public let titleLabel = UILabel()

    public init(issue: Issue, theme: Theme) {
        self.issue = issue
        self.theme = theme
        
        super.init(nibName: nil, bundle: nil)
        
        self.hidesBottomBarWhenPushed = true
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.containerView)
        self.containerView.addSubview(self.titleLabel)
        
        self.titleLabel.text = self.issue.title
        
        self.setupConstraints()
        self.styleViews()
    }
    
    
    // MARK: Private
    
    private func setupConstraints() {
        var screenBounds = UIScreen.mainScreen().bounds
        
        self.scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.scrollView.contentSize.width = self.view.bounds.width
        self.scrollView.autoPinEdgesToSuperviewEdges()
        
        self.containerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.containerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: ALEdge.Trailing)
        self.containerView.autoSetDimension(ALDimension.Width, toSize: screenBounds.width)
        
        self.titleLabel.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 8)
        self.titleLabel.autoAlignAxisToSuperviewAxis(.Vertical)
    }
    
    private func styleViews() {
        self.view.backgroundColor = self.theme.defaultBackgroundColor()
        self.titleLabel.font = self.theme.issueTitleFont()
        self.titleLabel.textColor = self.theme.issueTitleColor()
    }
}
