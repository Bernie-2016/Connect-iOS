import UIKit
import PureLayout

class NewsItemController: UIViewController {
    let newsItem: NewsItem
    let imageRepository: ImageRepository
    let humanTimeIntervalFormatter: HumanTimeIntervalFormatter
    let analyticsService: AnalyticsService
    let urlOpener: URLOpener
    let urlAttributionPresenter: URLAttributionPresenter
    let theme: Theme

    private let containerView = UIView.newAutoLayoutView()
    private let scrollView = UIScrollView.newAutoLayoutView()
    let dateLabel = UILabel.newAutoLayoutView()
    let titleButton = UIButton.newAutoLayoutView()
    let bodyTextView = UITextView.newAutoLayoutView()
    let storyImageView = UIImageView.newAutoLayoutView()
    let attributionLabel = UILabel.newAutoLayoutView()
    let viewOriginalButton = UIButton.newAutoLayoutView()

    init(
        newsItem: NewsItem,
        imageRepository: ImageRepository,
        humanTimeIntervalFormatter: HumanTimeIntervalFormatter,
        analyticsService: AnalyticsService,
        urlOpener: URLOpener,
        urlAttributionPresenter: URLAttributionPresenter,
        theme: Theme) {

        self.newsItem = newsItem
        self.imageRepository = imageRepository
        self.humanTimeIntervalFormatter = humanTimeIntervalFormatter
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
        self.urlAttributionPresenter = urlAttributionPresenter
        self.theme = theme

        super.init(nibName: nil, bundle: nil)

        self.hidesBottomBarWhenPushed = true
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Global_share", comment: ""), style: .Plain, target: self, action: "share")

        view.backgroundColor = self.theme.defaultBackgroundColor()

        view.addSubview(self.scrollView)
        scrollView.addSubview(self.containerView)
        containerView.addSubview(self.storyImageView)
        containerView.addSubview(self.dateLabel)
        containerView.addSubview(self.titleButton)
        containerView.addSubview(self.bodyTextView)
        containerView.addSubview(self.attributionLabel)
        containerView.addSubview(self.viewOriginalButton)

        dateLabel.text = self.humanTimeIntervalFormatter.humanDaysSinceDate(self.newsItem.date)
        titleButton.setTitle(self.newsItem.title, forState: .Normal)
        titleButton.addTarget(self, action: "didTapViewOriginal:", forControlEvents: .TouchUpInside)
        bodyTextView.text = self.newsItem.body

        attributionLabel.text = self.urlAttributionPresenter.attributionTextForURL(newsItem.url)
        viewOriginalButton.setTitle(NSLocalizedString("NewsItem_viewOriginal", comment: ""), forState: .Normal)
        viewOriginalButton.addTarget(self, action: "didTapViewOriginal:", forControlEvents: .TouchUpInside)

        applyThemeToViews()
        setupConstraintsAndLayout()

        if self.newsItem.imageURL != nil {
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        self.analyticsService.trackCustomEventWithName("Tapped 'Back' on News Item", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.newsItem.url.absoluteString])
    }

    // MARK: Actions

    func share() {
        self.analyticsService.trackCustomEventWithName("Tapped 'Share' on News Item", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.newsItem.url.absoluteString])
        let activityVC = UIActivityViewController(activityItems: [newsItem.url], applicationActivities: nil)

        activityVC.completionWithItemsHandler = { activity, success, items, error in
            if error != nil {
                self.analyticsService.trackError(error!, context: "Failed to share News Item")
            } else {
                if success == true {
                    self.analyticsService.trackShareWithActivityType(activity!, contentName: self.newsItem.title, contentType: .NewsItem, id: self.newsItem.url.absoluteString)
                } else {
                    self.analyticsService.trackCustomEventWithName("Cancelled share of News Item", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.newsItem.url.absoluteString])
                }
            }
        }

        presentViewController(activityVC, animated: true, completion: nil)
    }

    func didTapViewOriginal(sender: UIButton) {
        let eventName = sender == self.titleButton ? "Tapped title on News Item" : "Tapped 'View Original' on News Item"
        analyticsService.trackCustomEventWithName(eventName, customAttributes: [AnalyticsServiceConstants.contentIDKey: newsItem.url.absoluteString])
        self.urlOpener.openURL(self.newsItem.url)
    }

    // MARK: Private

    // swiftlint:disable function_body_length
    private func setupConstraintsAndLayout() {
        let screenBounds = UIScreen.mainScreen().bounds

        self.scrollView.contentSize.width = self.view.bounds.width
        self.scrollView.autoPinEdgesToSuperviewEdges()

        self.containerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Trailing)
        self.containerView.autoSetDimension(.Width, toSize: screenBounds.width)

        self.storyImageView.contentMode = .ScaleAspectFill
        self.storyImageView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)
        self.storyImageView.autoSetDimension(.Height, toSize: screenBounds.height / 3)
        self.storyImageView.clipsToBounds = true

        let titleLabel = self.titleButton.titleLabel!

        titleLabel.numberOfLines = 3
        titleLabel.preferredMaxLayoutWidth = screenBounds.width - 8
        NSLayoutConstraint.autoSetPriority(1000, forConstraints: { () -> Void in
            self.titleButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.storyImageView, withOffset: 25)
        })

        NSLayoutConstraint.autoSetPriority(500, forConstraints: { () -> Void in
            self.titleButton.autoPinEdgeToSuperviewEdge(.Top, withInset: 25)
        })

        self.titleButton.contentHorizontalAlignment = .Left
        self.titleButton.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        self.titleButton.autoPinEdgeToSuperviewMargin(.Trailing)
        self.titleButton.layoutIfNeeded()
        self.titleButton.autoSetDimension(.Height, toSize: titleLabel.frame.height)

        self.dateLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.titleButton, withOffset: 5)
        self.dateLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        self.dateLabel.autoPinEdgeToSuperviewMargin(.Trailing)
        self.dateLabel.autoSetDimension(.Height, toSize: 20)

        self.bodyTextView.scrollEnabled = false
        self.bodyTextView.textContainerInset = UIEdgeInsetsZero
        self.bodyTextView.textContainer.lineFragmentPadding = 0;
        self.bodyTextView.editable = false

        self.bodyTextView.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.dateLabel, withOffset: 14)
        self.bodyTextView.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        self.bodyTextView.autoPinEdgeToSuperviewMargin(.Right)

        self.attributionLabel.numberOfLines = 0
        self.attributionLabel.textAlignment = .Center
        self.attributionLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.bodyTextView, withOffset: 16)
        self.attributionLabel.autoPinEdgeToSuperviewMargin(.Left)
        self.attributionLabel.autoPinEdgeToSuperviewMargin(.Right)

        self.viewOriginalButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.attributionLabel, withOffset: 16)
        self.viewOriginalButton.autoPinEdgesToSuperviewMarginsExcludingEdge(.Top)
    }
    // swiftlint:enable function_body_length

    private func applyThemeToViews() {
        self.dateLabel.font = self.theme.newsItemDateFont()
        self.dateLabel.textColor = self.theme.newsItemDateColor()
        self.self.titleButton.titleLabel!.font = self.theme.newsItemTitleFont()
        self.titleButton.setTitleColor(self.theme.newsItemTitleColor(), forState: .Normal)
        self.bodyTextView.font = self.theme.newsItemBodyFont()
        self.bodyTextView.textColor = self.theme.newsItemBodyColor()
        self.attributionLabel.font = self.theme.attributionFont()
        self.attributionLabel.textColor = self.theme.attributionTextColor()
        self.viewOriginalButton.backgroundColor = self.theme.defaultButtonBackgroundColor()
        self.viewOriginalButton.setTitleColor(self.theme.defaultButtonTextColor(), forState: .Normal)
        self.viewOriginalButton.titleLabel!.font = self.theme.defaultButtonFont()
    }
}
