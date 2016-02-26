import UIKit
import PureLayout
import CBGPromise

// swiftlint:disable type_body_length
class NewsArticleController: UIViewController {
    let newsArticle: NewsArticle
    let markdownConverter: MarkdownConverter
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
         markdownConverter: MarkdownConverter,
         imageService: ImageService,
         timeIntervalFormatter: TimeIntervalFormatter,
         analyticsService: AnalyticsService,
         urlOpener: URLOpener,
         urlAttributionPresenter: URLAttributionPresenter,
         theme: Theme) {

        self.newsArticle = newsArticle
        self.imageService = imageService
        self.markdownConverter = markdownConverter
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

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "navBarShareButton"), style: .Plain, target: self, action: "share")

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

        bodyTextView.attributedText = markdownConverter.convertToAttributedString(newsArticle.body)

        attributionLabel.text = self.urlAttributionPresenter.attributionTextForURL(newsArticle.url)
        viewOriginalButton.setImage(UIImage(named: "ViewOriginal"), forState: .Normal)
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

        scrollView.contentSize.width = view.bounds.width
        scrollView.autoPinEdgesToSuperviewEdges()

        containerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Trailing)
        containerViewWidthConstraint = containerView.autoSetDimension(.Width, toSize: screenBounds.width)

        storyImageView.contentMode = .ScaleAspectFill
        storyImageView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)
        storyImageView.autoSetDimension(.Height, toSize: screenBounds.height / 3)
        storyImageView.clipsToBounds = true

        titleLabel.numberOfLines = 0
        titleLabel.preferredMaxLayoutWidth = screenBounds.width - (defaultHorizontalMargin * 2)
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

        dateLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 5)
        dateLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        dateLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin)
        dateLabel.autoSetDimension(.Height, toSize: 20)

        bodyTextView.scrollEnabled = false
        bodyTextView.textContainer.lineFragmentPadding = 0
        bodyTextView.editable = false

        bodyTextView.autoPinEdge(.Top, toEdge: .Bottom, ofView: dateLabel, withOffset: 10)
        bodyTextView.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        bodyTextView.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin)

        viewOriginalButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: bodyTextView, withOffset: 16)
        viewOriginalButton.autoSetDimension(.Height, toSize: 54)
        viewOriginalButton.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        viewOriginalButton.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin)

        attributionLabel.numberOfLines = 0
        attributionLabel.textAlignment = .Center
        attributionLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: viewOriginalButton, withOffset: 16)
        attributionLabel.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 0, left: defaultHorizontalMargin, bottom: defaultHorizontalMargin, right: defaultVerticalMargin), excludingEdge: .Top)
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

        viewOriginalButton.layer.borderColor = theme.defaultButtonBorderColor().CGColor
        viewOriginalButton.layer.borderWidth = 1.0
        viewOriginalButton.layer.cornerRadius = 3.0
        viewOriginalButton.backgroundColor = theme.attributionButtonBackgroundColor()
    }
}
// swiftlint:enable type_body_length
