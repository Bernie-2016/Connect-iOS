import UIKit
import PureLayout
import CBGPromise

// swiftlint:disable type_body_length
class NewsArticleController: UIViewController {
    let newsArticle: NewsArticle
    let imageService: ImageService
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

    init(newsArticle: NewsArticle,
         imageService: ImageService,
         timeIntervalFormatter: TimeIntervalFormatter,
         analyticsService: AnalyticsService,
         urlOpener: URLOpener,
         urlAttributionPresenter: URLAttributionPresenter,
         theme: Theme) {

        self.newsArticle = newsArticle
        self.imageService = imageService
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

        view.backgroundColor = theme.contentBackgroundColor()

        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(storyImageView)
        containerView.addSubview(dateLabel)
        containerView.addSubview(titleButton)
        containerView.addSubview(bodyTextView)
        containerView.addSubview(attributionLabel)
        containerView.addSubview(viewOriginalButton)

        dateLabel.text = self.timeIntervalFormatter.humanDaysSinceDate(self.newsArticle.date)
        titleButton.setTitle(self.newsArticle.title, forState: .Normal)
        titleButton.addTarget(self, action: "didTapViewOriginal:", forControlEvents: .TouchUpInside)
        bodyTextView.text = self.newsArticle.body

        attributionLabel.text = self.urlAttributionPresenter.attributionTextForURL(newsArticle.url)
        viewOriginalButton.setTitle(NSLocalizedString("NewsArticle_viewOriginal", comment: ""), forState: .Normal)
        viewOriginalButton.addTarget(self, action: "didTapViewOriginal:", forControlEvents: .TouchUpInside)

        applyThemeToViews()
        setupConstraintsAndLayout()

        guard let imageURL = newsArticle.imageURL else {
            self.storyImageView.removeFromSuperview()
            return
        }

        let imageFuture = imageService.fetchImageWithURL(imageURL)
        imageFuture.then { image in self.storyImageView.image = image }
        imageFuture.error { error in self.storyImageView.removeFromSuperview() }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            self.analyticsService.trackBackButtonTapOnScreen("News Item", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.newsArticle.url.absoluteString])
        }
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
        let defaultHorizontalMargin: CGFloat = 15
        let defaultVerticalMargin: CGFloat = 21

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

        NSLayoutConstraint.autoSetPriority(1000, forConstraints: {
            self.titleButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.storyImageView, withOffset: defaultVerticalMargin + 5)
        })

        NSLayoutConstraint.autoSetPriority(500, forConstraints: {
            self.titleButton.autoPinEdgeToSuperviewEdge(.Top, withInset: defaultVerticalMargin)
        })

        titleButton.contentHorizontalAlignment = .Left
        titleButton.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        titleButton.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin)
        titleButton.layoutIfNeeded()
        titleButton.autoSetDimension(.Height, toSize: titleLabel.frame.height)
        dateLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.titleButton, withOffset: 5)
        dateLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        dateLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin)
        dateLabel.autoSetDimension(.Height, toSize: 20)

        bodyTextView.scrollEnabled = false
        bodyTextView.textContainerInset = UIEdgeInsetsMake(-22, 0, 0, 0)
        bodyTextView.textContainer.lineFragmentPadding = 0
        bodyTextView.editable = false

        bodyTextView.autoPinEdge(.Top, toEdge: .Bottom, ofView: dateLabel, withOffset: defaultVerticalMargin - 5)
        bodyTextView.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        bodyTextView.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin)

        attributionLabel.numberOfLines = 0
        attributionLabel.textAlignment = .Center
        attributionLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.bodyTextView, withOffset: 16)
        attributionLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        attributionLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin)

        viewOriginalButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.attributionLabel, withOffset: 16)
        viewOriginalButton.autoSetDimension(.Height, toSize: 54)
        viewOriginalButton.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 0, left: defaultHorizontalMargin, bottom: defaultHorizontalMargin, right: defaultVerticalMargin), excludingEdge: .Top)
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
