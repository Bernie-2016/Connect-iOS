import UIKit
import PureLayout

public class IssueController : UIViewController {
    public let issue: Issue!
    public let imageRepository: ImageRepository!
    public let analyticsService: AnalyticsService!
    public let urlOpener: URLOpener!
    public let urlAttributionPresenter: URLAttributionPresenter!
    public let theme: Theme!
    
    let containerView = UIView()
    let scrollView = UIScrollView()
    public let titleLabel = UILabel()
    public let bodyTextView = UITextView()
    public let issueImageView = UIImageView()
    public let attributionLabel = UILabel.newAutoLayoutView()
    public let viewOriginalButton = UIButton.newAutoLayoutView()

    public init(issue: Issue,
        imageRepository: ImageRepository,
        analyticsService: AnalyticsService,
        urlOpener: URLOpener,
        urlAttributionPresenter: URLAttributionPresenter,
        theme: Theme) {
        self.issue = issue
        self.imageRepository = imageRepository
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
        self.urlAttributionPresenter = urlAttributionPresenter
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "share")

        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(issueImageView)
        containerView.addSubview(bodyTextView)
        containerView.addSubview(attributionLabel)
        containerView.addSubview(viewOriginalButton)
        
        titleLabel.text = self.issue.title
        bodyTextView.text = self.issue.body
        
        attributionLabel.text = self.urlAttributionPresenter.attributionTextForURL(issue.URL)
        viewOriginalButton.setTitle(NSLocalizedString("Issue_viewOriginal", comment: ""), forState: .Normal)
        viewOriginalButton.addTarget(self, action: "didTapViewOriginal", forControlEvents: .TouchUpInside)
        
        setupConstraintsAndLayout()
        applyThemeToViews()
        
        if(issue.imageURL != nil) {
            imageRepository.fetchImageWithURL(self.issue.imageURL!).then({ (image) -> AnyObject! in
                self.issueImageView.image = image as? UIImage
                return image
                }, error: { (error) -> AnyObject! in
                    self.issueImageView.removeFromSuperview()
                    return error
            })
        } else {
            issueImageView.removeFromSuperview()
        }
    }
    
    public override func didMoveToParentViewController(parent: UIViewController?) {
        analyticsService.trackCustomEventWithName("Tapped 'Back' on Issue", customAttributes: [AnalyticsServiceConstants.contentIDKey: issue.URL.absoluteString!])
    }

    
    // MARK: Actions
    
    func share() {
        analyticsService.trackCustomEventWithName("Tapped 'Share' on Issue", customAttributes: [AnalyticsServiceConstants.contentIDKey: issue.URL.absoluteString!])
        
        let activityVC = UIActivityViewController(activityItems: [issue.URL], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            if(error != nil) {
                self.analyticsService.trackError(error, context: "Failed to share Issue")
            } else {
                if(success == true) {
                    self.analyticsService.trackShareWithActivityType(activity, contentName: self.issue.title, contentType: .Issue, id: self.issue.URL.absoluteString!)
                } else {
                    self.analyticsService.trackCustomEventWithName("Cancelled share of Issue", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.issue.URL.absoluteString!])
                }
            }
        }
        
        presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func didTapViewOriginal() {
        analyticsService.trackCustomEventWithName("Tapped 'View Original' on Issue", customAttributes: [AnalyticsServiceConstants.contentIDKey: issue.URL.absoluteString!])
        self.urlOpener.openURL(self.issue.URL)
    }
    
    // MARK: Private
    
    private func setupConstraintsAndLayout() {
        var screenBounds = UIScreen.mainScreen().bounds
        
        self.scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.scrollView.contentSize.width = self.view.bounds.width
        self.scrollView.autoPinEdgesToSuperviewEdges()
        
        self.containerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.containerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: ALEdge.Trailing)
        self.containerView.autoSetDimension(ALDimension.Width, toSize: screenBounds.width)
        
        self.issueImageView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: ALEdge.Bottom)
        self.issueImageView.autoSetDimension(ALDimension.Height, toSize: screenBounds.height / 3, relation: NSLayoutRelation.LessThanOrEqual)
        
        NSLayoutConstraint.autoSetPriority(1000, forConstraints: { () -> Void in
            self.titleLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: self.issueImageView, withOffset: 8)
        })
        
        NSLayoutConstraint.autoSetPriority(500, forConstraints: { () -> Void in
            self.titleLabel.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 8)
        })
        

        self.titleLabel.numberOfLines = 3
        self.titleLabel.preferredMaxLayoutWidth = screenBounds.width - 8
        self.titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.titleLabel.autoPinEdgeToSuperviewEdge(ALEdge.Leading, withInset: 8)
        self.titleLabel.autoPinEdgeToSuperviewEdge(ALEdge.Trailing)
        self.titleLabel.autoSetDimension(ALDimension.Height, toSize: 20, relation: NSLayoutRelation.GreaterThanOrEqual)
        
        self.bodyTextView.scrollEnabled = false
        self.bodyTextView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.bodyTextView.textContainerInset = UIEdgeInsetsZero
        self.bodyTextView.textContainer.lineFragmentPadding = 0;
        self.bodyTextView.editable = false
        
        self.bodyTextView.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: self.titleLabel, withOffset: 16)
        self.bodyTextView.autoPinEdgeToSuperviewMargin(.Left)
        self.bodyTextView.autoPinEdgeToSuperviewMargin(.Right)
        
        self.attributionLabel.numberOfLines = 0
        self.attributionLabel.textAlignment = .Center
        self.attributionLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: self.bodyTextView, withOffset: 16)
        self.attributionLabel.autoPinEdgeToSuperviewMargin(.Left)
        self.attributionLabel.autoPinEdgeToSuperviewMargin(.Right)

        self.viewOriginalButton.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: self.attributionLabel, withOffset: 16)
        self.viewOriginalButton.autoPinEdgesToSuperviewMarginsExcludingEdge(.Top)
    }
    
    private func applyThemeToViews() {
        self.view.backgroundColor = self.theme.defaultBackgroundColor()
        self.titleLabel.font = self.theme.issueTitleFont()
        self.titleLabel.textColor = self.theme.issueTitleColor()
        self.bodyTextView.font = self.theme.issueBodyFont()
        self.bodyTextView.textColor = self.theme.issueBodyColor()
        self.attributionLabel.font = self.theme.attributionFont()
        self.attributionLabel.textColor = self.theme.attributionTextColor()
        self.viewOriginalButton.backgroundColor = self.theme.issueViewOriginalButtonBackgroundColor()
        self.viewOriginalButton.setTitleColor(self.theme.issueViewOriginalButtonTextColor(), forState: .Normal)
        self.viewOriginalButton.titleLabel!.font = self.theme.issueViewOriginalButtonFont()
    }
}
