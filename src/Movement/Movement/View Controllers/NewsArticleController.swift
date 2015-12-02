import UIKit
import PureLayout

// swiftlint:disable type_body_length
class NewsArticleController: UIViewController {
    let newsArticle: NewsArticle
    let imageRepository: ImageRepository
    let timeIntervalFormatter: TimeIntervalFormatter
    let analyticsService: AnalyticsService
    let urlOpener: URLOpener
    let urlAttributionPresenter: URLAttributionPresenter
    let theme: Theme

    private let containerView = UIView.newAutoLayoutView()
    private var containerViewWidthConstraint: NSLayoutConstraint!
    private let scrollView = UIScrollView.newAutoLayoutView()
    let dateLabel = UILabel.newAutoLayoutView()
    let titleButton = UIButton.newAutoLayoutView()
    let bodyTextView = UITextView.newAutoLayoutView()
    let storyImageView = UIImageView.newAutoLayoutView()
    let attributionLabel = UILabel.newAutoLayoutView()
    let viewOriginalButton = UIButton.newAutoLayoutView()

    init(
        newsArticle: NewsArticle,
        imageRepository: ImageRepository,
        timeIntervalFormatter: TimeIntervalFormatter,
        analyticsService: AnalyticsService,
        urlOpener: URLOpener,
        urlAttributionPresenter: URLAttributionPresenter,
        theme: Theme) {

        self.newsArticle = newsArticle
        self.imageRepository = imageRepository
        self.timeIntervalFormatter = timeIntervalFormatter
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

        dateLabel.text = self.timeIntervalFormatter.humanDaysSinceDate(self.newsArticle.date)
        titleButton.setTitle(self.newsArticle.title, forState: .Normal)
        titleButton.addTarget(self, action: "didTapViewOriginal:", forControlEvents: .TouchUpInside)
        bodyTextView.text = self.newsArticle.body

        attributionLabel.text = self.urlAttributionPresenter.attributionTextForURL(newsArticle.url)
        viewOriginalButton.setTitle(NSLocalizedString("NewsArticle_viewOriginal", comment: ""), forState: .Normal)
        viewOriginalButton.addTarget(self, action: "didTapViewOriginal:", forControlEvents: .TouchUpInside)

        applyThemeToViews()
        setupConstraintsAndLayout()

        if self.newsArticle.imageURL != nil {
            self.imageRepository.fetchImageWithURL(self.newsArticle.imageURL!).then({ (image) -> AnyObject! in
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
        self.analyticsService.trackBackButtonTapOnScreen("News Item", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.newsArticle.url.absoluteString])
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

        let screenBounds = UIScreen.mainScreen().bounds
        self.containerViewWidthConstraint.constant = screenBounds.width
    }

    // MARK: Actions

    func share() {
        self.analyticsService.trackCustomEventWithName("Began Share", customAttributes: [
            AnalyticsServiceConstants.contentIDKey: self.newsArticle.url.absoluteString,
            AnalyticsServiceConstants.contentNameKey: self.newsArticle.title,
            AnalyticsServiceConstants.contentTypeKey: AnalyticsServiceContentType.NewsArticle.description
            ])
        let activityVC = UIActivityViewController(activityItems: [newsArticle.url], applicationActivities: nil)

        activityVC.completionWithItemsHandler = { activity, success, items, error in
            if error != nil {
                self.analyticsService.trackError(error!, context: "Failed to share News Item")
            } else {
                if success == true {
                    self.analyticsService.trackShareWithActivityType(activity!, contentName: self.newsArticle.title, contentType: .NewsArticle, identifier: self.newsArticle.url.absoluteString)
                } else {
                    self.analyticsService.trackCustomEventWithName("Cancelled Share", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.newsArticle.url.absoluteString,
                        AnalyticsServiceConstants.contentNameKey: self.newsArticle.title,
                        AnalyticsServiceConstants.contentTypeKey: AnalyticsServiceContentType.NewsArticle.description
                        ])
                }
            }
        }

        presentViewController(activityVC, animated: true, completion: nil)
    }

    func didTapViewOriginal(sender: UIButton) {
        let eventName = sender == self.titleButton ? "Tapped title on News Item" : "Tapped 'View Original' on News Item"
        analyticsService.trackCustomEventWithName(eventName, customAttributes: [AnalyticsServiceConstants.contentIDKey: newsArticle.url.absoluteString])
        self.urlOpener.openURL(self.newsArticle.url)
    }

    // MARK: Private

    // swiftlint:disable function_body_length
    private func setupConstraintsAndLayout() {
        let screenBounds = UIScreen.mainScreen().bounds

        self.scrollView.contentSize.width = self.view.bounds.width
        self.scrollView.autoPinEdgesToSuperviewEdges()

        self.containerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Trailing)
        self.containerViewWidthConstraint = self.containerView.autoSetDimension(.Width, toSize: screenBounds.width)

        self.storyImageView.contentMode = .ScaleAspectFill
        self.storyImageView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)
        self.storyImageView.autoSetDimension(.Height, toSize: screenBounds.height / 3)
        self.storyImageView.clipsToBounds = true

        let titleLabel = self.titleButton.titleLabel!

        titleLabel.numberOfLines = 0
        titleLabel.preferredMaxLayoutWidth = screenBounds.width - 8
        NSLayoutConstraint.autoSetPriority(1000, forConstraints: { () -> Void in
            self.titleButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.storyImageView, withOffset: 25)
        })

        NSLayoutConstraint.autoSetPriority(500, forConstraints: { () -> Void in
            self.titleButton.autoPinEdgeToSuperviewEdge(.Top, withInset: 25)
        })

        titleButton.contentHorizontalAlignment = .Left
        titleButton.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        titleButton.autoPinEdgeToSuperviewMargin(.Trailing)
        titleButton.layoutIfNeeded()
        titleButton.autoSetDimension(.Height, toSize: titleLabel.frame.height)

        dateLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.titleButton, withOffset: 5)
        dateLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        dateLabel.autoPinEdgeToSuperviewMargin(.Trailing)
        dateLabel.autoSetDimension(.Height, toSize: 20)

        bodyTextView.scrollEnabled = false
        bodyTextView.textContainerInset = UIEdgeInsetsZero
        bodyTextView.textContainer.lineFragmentPadding = 0
        bodyTextView.editable = false

        bodyTextView.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.dateLabel, withOffset: 14)
        bodyTextView.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        bodyTextView.autoPinEdgeToSuperviewMargin(.Right)

        attributionLabel.numberOfLines = 0
        attributionLabel.textAlignment = .Center
        attributionLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.bodyTextView, withOffset: 16)
        attributionLabel.autoPinEdgeToSuperviewMargin(.Left)
        attributionLabel.autoPinEdgeToSuperviewMargin(.Right)

        viewOriginalButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.attributionLabel, withOffset: 16)
        viewOriginalButton.autoSetDimension(.Height, toSize: 54)
        viewOriginalButton.autoPinEdgesToSuperviewMarginsExcludingEdge(.Top)
    }
    // swiftlint:enable function_body_length

    private func applyThemeToViews() {
        self.dateLabel.font = self.theme.newsArticleDateFont()
        self.dateLabel.textColor = self.theme.newsArticleDateColor()
        self.self.titleButton.titleLabel!.font = self.theme.newsArticleTitleFont()
        self.titleButton.setTitleColor(self.theme.newsArticleTitleColor(), forState: .Normal)
        self.bodyTextView.font = self.theme.newsArticleBodyFont()
        self.bodyTextView.textColor = self.theme.newsArticleBodyColor()
        self.attributionLabel.font = self.theme.attributionFont()
        self.attributionLabel.textColor = self.theme.attributionTextColor()
        self.viewOriginalButton.backgroundColor = self.theme.defaultButtonBackgroundColor()
        self.viewOriginalButton.setTitleColor(self.theme.defaultButtonTextColor(), forState: .Normal)
        self.viewOriginalButton.titleLabel!.font = self.theme.defaultButtonFont()
    }
}
// swiftlint:enable type_body_length
