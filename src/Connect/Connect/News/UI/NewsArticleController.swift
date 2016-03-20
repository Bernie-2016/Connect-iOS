import UIKit
import PureLayout
import CBGPromise
import AMScrollingNavbar

// swiftlint:disable type_body_length
class NewsArticleController: UIViewController {
    let newsArticle: NewsArticle
    let markdownConverter: MarkdownConverter
    let imageService: ImageService
    let timeIntervalFormatter: TimeIntervalFormatter
    let analyticsService: AnalyticsService
    let urlOpener: URLOpener
    let theme: Theme

    private let containerView = UIView.newAutoLayoutView()
    private var containerViewWidthConstraint: NSLayoutConstraint!
    private let scrollView = UIScrollView.newAutoLayoutView()
    let dateLabel = UILabel.newAutoLayoutView()
    let titleLabel = UILabel.newAutoLayoutView()
    let bodyTextView = UITextView.newAutoLayoutView()
    let storyImageView = UIImageView.newAutoLayoutView()

    init(newsArticle: NewsArticle,
        markdownConverter: MarkdownConverter,
        imageService: ImageService,
        timeIntervalFormatter: TimeIntervalFormatter,
        analyticsService: AnalyticsService,
        urlOpener: URLOpener,
        theme: Theme) {

            self.newsArticle = newsArticle
            self.imageService = imageService
            self.markdownConverter = markdownConverter
            self.timeIntervalFormatter = timeIntervalFormatter
            self.analyticsService = analyticsService
            self.urlOpener = urlOpener
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

        scrollView.delegate = self

        dateLabel.text = timeIntervalFormatter.humanDaysSinceDate(self.newsArticle.date)
        titleLabel.text = newsArticle.title

        bodyTextView.attributedText = markdownConverter.convertToAttributedString(newsArticle.body)

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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(scrollView, delay: 50.0)
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


    // MARK: Private
    // swiftlint:disable function_body_length
    private func setupConstraintsAndLayout() {
        let defaultHorizontalMargin: CGFloat = 15
        let defaultVerticalMargin: CGFloat = 14

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

        bodyTextView.autoPinEdge(.Top, toEdge: .Bottom, ofView: dateLabel, withOffset: defaultVerticalMargin - 14)
        bodyTextView.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        bodyTextView.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin)
        bodyTextView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: defaultHorizontalMargin)
    }

    // swiftlint:enable function_body_length

    private func applyThemeToViews() {
        dateLabel.font = theme.newsArticleDateFont()
        dateLabel.textColor = theme.newsArticleDateColor()
        titleLabel.font = theme.newsArticleTitleFont()
        titleLabel.textColor = theme.newsArticleTitleColor()
        bodyTextView.font = theme.newsArticleBodyFont()
        bodyTextView.textColor = theme.newsArticleBodyColor()
    }
}

extension NewsArticleController: UIScrollViewDelegate {
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.showNavbar(animated: true)
        }
        return true
    }
}
// swiftlint:enable type_body_length
