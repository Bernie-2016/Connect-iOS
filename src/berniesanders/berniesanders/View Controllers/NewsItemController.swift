import UIKit
import PureLayout

public class NewsItemController : UIViewController {
    private(set) public var newsItem : NewsItem!
    private(set) public var imageRepository : ImageRepository!
    private(set) public var dateFormatter : NSDateFormatter!
    private(set) public var theme : Theme!
    
    let containerView = UIView()
    let scrollView = UIScrollView()
    public let dateLabel = UILabel()
    public let titleLabel = UILabel()
    public let bodyTextView = UITextView()
    public let storyImageView = UIImageView()
    
    public init(
        newsItem: NewsItem,
        dateFormatter: NSDateFormatter,
        imageRepository: ImageRepository,
        theme: Theme) {

        self.newsItem = newsItem
        self.dateFormatter = dateFormatter
        self.imageRepository = imageRepository
        self.theme = theme
        
        super.init(nibName: nil, bundle: nil)
            
        self.hidesBottomBarWhenPushed = true
    }
    
    // MARK: UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes = [
            NSFontAttributeName: theme.tabBarFont(),
            NSForegroundColorAttributeName: theme.tabBarTextColor()
        ]
        
        self.tabBarItem.setTitleTextAttributes(attributes, forState: .Selected)
        
        var screenBounds = UIScreen.mainScreen().bounds
        
        self.view.backgroundColor = self.theme.defaultBackgroundColor()

        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.containerView)
        self.containerView.addSubview(self.storyImageView)
        self.containerView.addSubview(self.dateLabel)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.bodyTextView)
        
        self.scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.scrollView.contentSize.width = self.view.bounds.width
        self.scrollView.autoPinEdgesToSuperviewEdges()
        
        self.containerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.containerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: ALEdge.Trailing)
        self.containerView.autoSetDimension(ALDimension.Width, toSize: screenBounds.width)
        
        self.storyImageView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: ALEdge.Bottom)
        self.storyImageView.autoSetDimension(ALDimension.Height, toSize: screenBounds.height / 3, relation: NSLayoutRelation.LessThanOrEqual)

        self.dateLabel.font = self.theme.newsItemDateFont()
        self.dateLabel.textColor = self.theme.newsItemDateColor()
        self.dateLabel.text = self.dateFormatter.stringFromDate(self.newsItem.date)
        
        NSLayoutConstraint.autoSetPriority(1000, forConstraints: { () -> Void in
            self.dateLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: self.storyImageView, withOffset: 8)
        })

        NSLayoutConstraint.autoSetPriority(500, forConstraints: { () -> Void in
            self.dateLabel.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 8)
        })
        
        self.dateLabel.autoPinEdgeToSuperviewEdge(ALEdge.Leading, withInset: 8)
        self.dateLabel.autoPinEdgeToSuperviewEdge(ALEdge.Trailing)
        self.dateLabel.autoSetDimension(ALDimension.Height, toSize: 20) //, relation: NSLayoutRelation.GreaterThanOrEqual)
        
        self.titleLabel.font = self.theme.newsItemTitleFont()
        self.titleLabel.textColor = self.theme.newsItemTitleColor()
        self.titleLabel.text = self.newsItem.title
        self.titleLabel.numberOfLines = 3
        self.titleLabel.preferredMaxLayoutWidth = screenBounds.width - 8
        self.titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.titleLabel.autoPinEdgeToSuperviewEdge(ALEdge.Leading, withInset: 8)
        self.titleLabel.autoPinEdgeToSuperviewEdge(ALEdge.Trailing)
        self.titleLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: self.dateLabel)
        self.titleLabel.autoSetDimension(ALDimension.Height, toSize: 20, relation: NSLayoutRelation.GreaterThanOrEqual)

        self.bodyTextView.font = self.theme.newsItemBodyFont()
        self.bodyTextView.textColor = self.theme.newsItemBodyColor()
        self.bodyTextView.scrollEnabled = false
        self.bodyTextView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.bodyTextView.textContainerInset = UIEdgeInsetsZero
        self.bodyTextView.textContainer.lineFragmentPadding = 0;
        self.bodyTextView.text = self.newsItem.body
        self.bodyTextView.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: self.titleLabel, withOffset: 16)
        self.bodyTextView.autoPinEdgeToSuperviewEdge(ALEdge.Bottom)
        self.bodyTextView.autoPinEdgeToSuperviewEdge(ALEdge.Leading, withInset: 8)
        self.bodyTextView.autoPinEdgeToSuperviewEdge(ALEdge.Trailing)
        
        self.imageRepository.fetchImageWithURL(self.newsItem.imageURL).then({ (image) -> AnyObject! in
            self.storyImageView.image = image as? UIImage
            return image
        }, error: { (error) -> AnyObject! in
            self.storyImageView.removeFromSuperview()
            return error
        })
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
