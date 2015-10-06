import UIKit
import PureLayout

public class NewsItemController : UIViewController {
    public let newsItem : NewsItem!
    public let imageRepository : ImageRepository!
    public let dateFormatter : NSDateFormatter!
    public let analyticsService: AnalyticsService!
    public let urlOpener: URLOpener!
    public let urlAttributionPresenter: URLAttributionPresenter!
    public let theme : Theme!
    
    let containerView = UIView.newAutoLayoutView()
    let scrollView = UIScrollView.newAutoLayoutView()
    public let dateLabel = UILabel()
    public let titleLabel = UILabel()
    public let bodyTextView = UITextView()
    public let storyImageView = UIImageView()
    public let attributionLabel = UILabel.newAutoLayoutView()
    public let viewOriginalButton = UIButton.newAutoLayoutView()
    
    public init(
        newsItem: NewsItem,
        imageRepository: ImageRepository,
        dateFormatter: NSDateFormatter,
        analyticsService: AnalyticsService,
        urlOpener: URLOpener,
        urlAttributionPresenter: URLAttributionPresenter,
        theme: Theme) {

        self.newsItem = newsItem
        self.imageRepository = imageRepository
        self.dateFormatter = dateFormatter
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
        self.urlAttributionPresenter = urlAttributionPresenter
        self.theme = theme
        
        super.init(nibName: nil, bundle: nil)
            
        self.hidesBottomBarWhenPushed = true
    }
    
    // MARK: UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "share")
        
        view.backgroundColor = self.theme.defaultBackgroundColor()
        
        view.addSubview(self.scrollView)
        scrollView.addSubview(self.containerView)
        containerView.addSubview(self.storyImageView)
        containerView.addSubview(self.dateLabel)
        containerView.addSubview(self.titleLabel)
        containerView.addSubview(self.bodyTextView)
        containerView.addSubview(self.attributionLabel)
        containerView.addSubview(self.viewOriginalButton)
        
        dateLabel.text = self.dateFormatter.stringFromDate(self.newsItem.date)
        titleLabel.text = self.newsItem.title
        bodyTextView.text = self.newsItem.body
        
        attributionLabel.text = self.urlAttributionPresenter.attributionTextForURL(newsItem.URL)
        viewOriginalButton.setTitle(NSLocalizedString("NewsItem_viewOriginal", comment: ""), forState: .Normal)
        viewOriginalButton.addTarget(self, action: "didTapViewOriginal", forControlEvents: .TouchUpInside)

        setupConstraintsAndLayout()
        applyThemeToViews()
        
        if(self.newsItem.imageURL != nil) {
            self.imageRepository.fetchImageWithURL(self.newsItem.imageURL!).then({ (image) -> AnyObject! in
                self.storyImageView.image = image as? UIImage
                return image
                }, error: { (error) -> AnyObject! in
                    self.storyImageView.removeFromSuperview()
                    return error
            })
        } else {
            self.storyImageView.removeFromSuperview()
        }
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didMoveToParentViewController(parent: UIViewController?) {
        self.analyticsService.trackCustomEventWithName("Tapped 'Back' on News Item", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.newsItem.URL.absoluteString!])
    }
    
    // MARK: Actions
    
    func share() {
        self.analyticsService.trackCustomEventWithName("Tapped 'Share' on News Item", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.newsItem.URL.absoluteString!])
        let activityVC = UIActivityViewController(activityItems: [newsItem.URL], applicationActivities: nil)

        activityVC.completionWithItemsHandler = { activity, success, items, error in
            if(error != nil) {
                self.analyticsService.trackError(error, context: "Failed to share News Item")
            } else {
                if(success == true) {
                    self.analyticsService.trackShareWithActivityType(activity, contentName: self.newsItem.title, contentType: .NewsItem, id: self.newsItem.URL.absoluteString!)
                } else {
                    self.analyticsService.trackCustomEventWithName("Cancelled share of News Item", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.newsItem.URL.absoluteString!])
                }
            }
        }
        
        presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func didTapViewOriginal() {
        analyticsService.trackCustomEventWithName("Tapped 'View Original' on News Item", customAttributes: [AnalyticsServiceConstants.contentIDKey: newsItem.URL.absoluteString!])
        self.urlOpener.openURL(self.newsItem.URL)
    }
    
    // MARK: Private

    private func setupConstraintsAndLayout() {
        let screenBounds = UIScreen.mainScreen().bounds

        self.scrollView.contentSize.width = self.view.bounds.width
        self.scrollView.autoPinEdgesToSuperviewEdges()
        
        self.containerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: ALEdge.Trailing)
        self.containerView.autoSetDimension(ALDimension.Width, toSize: screenBounds.width)
        
        self.storyImageView.contentMode = .ScaleAspectFill
        self.storyImageView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: ALEdge.Bottom)
        self.storyImageView.autoSetDimension(ALDimension.Height, toSize: screenBounds.height / 3, relation: NSLayoutRelation.LessThanOrEqual)
        
        NSLayoutConstraint.autoSetPriority(1000, forConstraints: { () -> Void in
            self.dateLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: self.storyImageView, withOffset: 8)
        })
        
        NSLayoutConstraint.autoSetPriority(500, forConstraints: { () -> Void in
            self.dateLabel.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 8)
        })
        
        self.dateLabel.autoPinEdgeToSuperviewMargin(ALEdge.Leading)
        self.dateLabel.autoPinEdgeToSuperviewMargin(ALEdge.Trailing)
        self.dateLabel.autoSetDimension(ALDimension.Height, toSize: 20)
        
        self.titleLabel.numberOfLines = 3
        self.titleLabel.preferredMaxLayoutWidth = screenBounds.width - 8
        self.titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.titleLabel.autoPinEdgeToSuperviewMargin(.Leading)
        self.titleLabel.autoPinEdgeToSuperviewMargin(.Trailing)
        self.titleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.dateLabel)
        self.titleLabel.autoSetDimension(.Height, toSize: 20, relation: NSLayoutRelation.GreaterThanOrEqual)
        
        self.bodyTextView.scrollEnabled = false
        self.bodyTextView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.bodyTextView.textContainerInset = UIEdgeInsetsZero
        self.bodyTextView.textContainer.lineFragmentPadding = 0;
        self.bodyTextView.editable = false
        
        self.bodyTextView.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.titleLabel, withOffset: 16)
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
        self.dateLabel.font = self.theme.newsItemDateFont()
        self.dateLabel.textColor = self.theme.newsItemDateColor()
        self.titleLabel.font = self.theme.newsItemTitleFont()
        self.titleLabel.textColor = self.theme.newsItemTitleColor()
        self.bodyTextView.font = self.theme.newsItemBodyFont()
        self.bodyTextView.textColor = self.theme.newsItemBodyColor()
        self.attributionLabel.font = self.theme.attributionFont()
        self.attributionLabel.textColor = self.theme.attributionTextColor()
        self.viewOriginalButton.backgroundColor = self.theme.issueViewOriginalButtonBackgroundColor()
        self.viewOriginalButton.setTitleColor(self.theme.issueViewOriginalButtonTextColor(), forState: .Normal)
        self.viewOriginalButton.titleLabel!.font = self.theme.issueViewOriginalButtonFont()
    }
}
