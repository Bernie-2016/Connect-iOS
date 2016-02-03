import UIKit
import PureLayout
import CBGPromise

class IssueController: UIViewController {
    let issue: Issue
    let imageService: ImageService
    let analyticsService: AnalyticsService
    let urlOpener: URLOpener
    let urlAttributionPresenter: URLAttributionPresenter
    let theme: Theme

    private let containerView = UIView.newAutoLayoutView()
    private var containerViewWidthConstraint: NSLayoutConstraint!
    private let scrollView = UIScrollView.newAutoLayoutView()
    let titleLabel = UILabel.newAutoLayoutView()
    let bodyTextView = UITextView.newAutoLayoutView()
    let issueImageView = UIImageView.newAutoLayoutView()
    let attributionLabel = UILabel.newAutoLayoutView()
    let viewOriginalButton = UIButton.newAutoLayoutView()

    init(issue: Issue,
        imageService: ImageService,
        analyticsService: AnalyticsService,
        urlOpener: URLOpener,
        urlAttributionPresenter: URLAttributionPresenter,
        theme: Theme) {
        self.issue = issue
        self.imageService = imageService
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
        self.urlAttributionPresenter = urlAttributionPresenter
        self.theme = theme

        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Global_share", comment: ""), style: .Plain, target: self, action: "share")

        addSubviews()

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = theme.defaultBodyTextLineHeight()
        paragraphStyle.maximumLineHeight = theme.defaultBodyTextLineHeight()
        paragraphStyle.minimumLineHeight = theme.defaultBodyTextLineHeight()
        let attributedText = NSAttributedString(string: issue.body, attributes: [NSParagraphStyleAttributeName: paragraphStyle])

        bodyTextView.attributedText = attributedText
        titleLabel.text = issue.title

        attributionLabel.text = urlAttributionPresenter.attributionTextForURL(issue.url)
        viewOriginalButton.setImage(UIImage(named: "ViewOriginal"), forState: .Normal)
        viewOriginalButton.addTarget(self, action: "didTapViewOriginal:", forControlEvents: .TouchUpInside)

        setupConstraintsAndLayout()
        applyThemeToViews()

        guard let imageURL = issue.imageURL else {
            issueImageView.removeFromSuperview()
            return
        }

        let imageFuture = imageService.fetchImageWithURL(imageURL)
        imageFuture.then { image in
            UIView.transitionWithView(self.issueImageView, duration: 0.3, options: .TransitionCrossDissolve, animations: {
                self.issueImageView.image = image
                }, completion: nil)
        }
        imageFuture.error { error in
            UIView.transitionWithView(self.issueImageView, duration: 0.3, options: .TransitionCrossDissolve, animations: {
                self.issueImageView.removeFromSuperview()
                }, completion: nil)
        }
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            analyticsService.trackBackButtonTapOnScreen("Issue", customAttributes: [AnalyticsServiceConstants.contentIDKey: issue.url.absoluteString])
        }
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

        let screenBounds = UIScreen.mainScreen().bounds
        containerViewWidthConstraint.constant = screenBounds.width
    }

    // MARK: Actions

    func share() {
        analyticsService.trackCustomEventWithName("Began Share", customAttributes: [AnalyticsServiceConstants.contentIDKey: issue.url.absoluteString,
            AnalyticsServiceConstants.contentNameKey: issue.title,
            AnalyticsServiceConstants.contentTypeKey: AnalyticsServiceContentType.Issue.description
            ])

        let activityVC = UIActivityViewController(activityItems: [issue.url], applicationActivities: nil)
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            if error != nil {
                self.analyticsService.trackError(error!, context: "Failed to share Issue")
            } else {
                if success == true {
                    self.analyticsService.trackShareWithActivityType(activity!, contentName: self.issue.title, contentType: .Issue, identifier: self.issue.url.absoluteString)
                } else {
                    self.analyticsService.trackCustomEventWithName("Cancelled Share", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.issue.url.absoluteString,
                        AnalyticsServiceConstants.contentNameKey: self.issue.title,
                        AnalyticsServiceConstants.contentTypeKey: AnalyticsServiceContentType.Issue.description
                        ])
                }
            }
        }

        presentViewController(activityVC, animated: true, completion: nil)
    }

    func didTapViewOriginal(sender: UIButton) {
        let eventName = sender == titleLabel ? "Tapped title on Issue" : "Tapped 'View Original' on Issue"
        analyticsService.trackCustomEventWithName(eventName, customAttributes: [AnalyticsServiceConstants.contentIDKey: issue.url.absoluteString])
        urlOpener.openURL(issue.url)
    }
}

// MARK: Private
extension IssueController {
    // swiftlint:disable function_body_length
    private func setupConstraintsAndLayout() {
        let defaultHorizontalMargin: CGFloat = 15
        let defaultVerticalMargin: CGFloat = 21
        let screenBounds = UIScreen.mainScreen().bounds

        scrollView.contentSize.width = view.bounds.width
        scrollView.autoPinEdgesToSuperviewEdges()

        containerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Trailing)
        containerViewWidthConstraint = containerView.autoSetDimension(.Width, toSize: screenBounds.width)

        issueImageView.contentMode = .ScaleAspectFill
        issueImageView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)
        issueImageView.autoSetDimension(.Height, toSize: screenBounds.height / 3, relation: NSLayoutRelation.LessThanOrEqual)
        issueImageView.clipsToBounds = true

        NSLayoutConstraint.autoSetPriority(1000, forConstraints: { () -> Void in
            self.titleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.issueImageView, withOffset: defaultVerticalMargin)
        })

        NSLayoutConstraint.autoSetPriority(500, forConstraints: { () -> Void in
            self.titleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: defaultVerticalMargin)
        })

        titleLabel.numberOfLines = 0
        titleLabel.preferredMaxLayoutWidth = screenBounds.width - defaultHorizontalMargin
        titleLabel.textAlignment = .Left
        titleLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        titleLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin)

        bodyTextView.scrollEnabled = false
        bodyTextView.translatesAutoresizingMaskIntoConstraints = false
        bodyTextView.textContainer.lineFragmentPadding = 0
        bodyTextView.editable = false
        bodyTextView.selectable = false

        bodyTextView.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 0)
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
        view.backgroundColor = theme.contentBackgroundColor()
        titleLabel.font = theme.issueTitleFont()
        titleLabel.textColor = theme.issueTitleColor()
        bodyTextView.font = theme.issueBodyFont()
        bodyTextView.textColor = theme.issueBodyColor()
        attributionLabel.font = theme.attributionFont()
        attributionLabel.textColor = theme.attributionTextColor()

        viewOriginalButton.backgroundColor = theme.attributionButtonBackgroundColor()
        viewOriginalButton.layer.borderColor = theme.defaultButtonBorderColor().CGColor
        viewOriginalButton.layer.borderWidth = 1.0
        viewOriginalButton.layer.cornerRadius = 3.0
    }

    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(issueImageView)
        containerView.addSubview(bodyTextView)
        containerView.addSubview(attributionLabel)
        containerView.addSubview(viewOriginalButton)
    }
}
