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
    let titleLabel = UILabel.newAutoLayoutView()
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
        containerView.addSubview(titleLabel)
        containerView.addSubview(bodyTextView)
        containerView.addSubview(attributionLabel)
        containerView.addSubview(viewOriginalButton)

        dateLabel.text = timeIntervalFormatter.humanDaysSinceDate(self.newsArticle.date)
        titleLabel.text = newsArticle.title
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
        imageFuture.then { image in
            UIView.transitionWithView(self.storyImageView, duration: 0.3, options: .TransitionCrossDissolve, animations: {
                self.storyImageView.image = image
                }, completion: nil)
        }
        imageFuture.error { error in
            UIView.transitionWithView(self.storyImageView, duration: 0.3, options: .TransitionCrossDissolve, animations: {
                self.storyImageView.removeFromSuperview()
                }, completion: nil)
        }
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
        let eventName = sender == self.titleLabel ? "Tapped title on News Item" : "Tapped 'View Original' on News Item"
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

        titleLabel.numberOfLines = 0
        titleLabel.preferredMaxLayoutWidth = screenBounds.width - defaultHorizontalMargin
        titleLabel.textAlignment = .Left

        NSLayoutConstraint.autoSetPriority(1000, forConstraints: {
            self.titleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.storyImageView, withOffset: defaultVerticalMargin + 5)
        })

        NSLayoutConstraint.autoSetPriority(500, forConstraints: {
            self.titleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: defaultVerticalMargin)
        })

        titleLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        titleLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin)
        titleLabel.layoutIfNeeded()

        dateLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.titleLabel, withOffset: 5)
        dateLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        dateLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin)
        dateLabel.autoSetDimension(.Height, toSize: 20)

        bodyTextView.scrollEnabled = false
        bodyTextView.textContainer.lineFragmentPadding = 0
        bodyTextView.editable = false

        bodyTextView.autoPinEdge(.Top, toEdge: .Bottom, ofView: dateLabel, withOffset: 10)
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
        dateLabel.font = theme.newsArticleDateFont()
        dateLabel.textColor = theme.newsArticleDateColor()
        titleLabel.font = theme.newsArticleTitleFont()
        titleLabel.textColor = theme.newsArticleTitleColor()
        bodyTextView.font = theme.newsArticleBodyFont()
        bodyTextView.textColor = theme.newsArticleBodyColor()
        attributionLabel.font = theme.attributionFont()
        attributionLabel.textColor = theme.attributionTextColor()
        viewOriginalButton.backgroundColor = theme.defaultButtonBackgroundColor()
        viewOriginalButton.setTitleColor(theme.defaultButtonTextColor(), forState: .Normal)
        viewOriginalButton.titleLabel!.font = theme.defaultButtonFont()
    }
}
// swiftlint:enable type_body_length
