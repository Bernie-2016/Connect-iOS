import UIKit
import PureLayout
import BrightFutures
import Result

class IssueController: UIViewController {
    let issue: Issue
    let imageRepository: ImageRepository
    let analyticsService: AnalyticsService
    let urlOpener: URLOpener
    let urlAttributionPresenter: URLAttributionPresenter
    let theme: Theme

    private let containerView = UIView()
    private var containerViewWidthConstraint: NSLayoutConstraint!
    private let scrollView = UIScrollView()
    let titleButton = UIButton.newAutoLayoutView()
    let bodyTextView = UITextView.newAutoLayoutView()
    let issueImageView = UIImageView.newAutoLayoutView()
    let attributionLabel = UILabel.newAutoLayoutView()
    let viewOriginalButton = UIButton.newAutoLayoutView()

    init(issue: Issue,
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Global_share", comment: ""), style: .Plain, target: self, action: "share")

        self.addSubviews()

        bodyTextView.text = self.issue.body
        titleButton.setTitle(self.issue.title, forState: .Normal)
        titleButton.addTarget(self, action: "didTapViewOriginal:", forControlEvents: .TouchUpInside)

        attributionLabel.text = self.urlAttributionPresenter.attributionTextForURL(issue.url)
        viewOriginalButton.setTitle(NSLocalizedString("Issue_viewOriginal", comment: ""), forState: .Normal)
        viewOriginalButton.addTarget(self, action: "didTapViewOriginal:", forControlEvents: .TouchUpInside)

        setupConstraintsAndLayout()
        applyThemeToViews()

        if issue.imageURL != nil {
            imageRepository.fetchImageWithURL(self.issue.imageURL!).onSuccess(ImmediateOnMainExecutionContext, callback: { (image) -> Void in
                self.issueImageView.image = image
            }).onFailure(ImmediateOnMainExecutionContext, callback: { (error) -> Void in
                    self.issueImageView.removeFromSuperview()
            })
        } else {
            issueImageView.removeFromSuperview()
        }
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        self.analyticsService.trackBackButtonTapOnScreen("Issue", customAttributes: [AnalyticsServiceConstants.contentIDKey: issue.url.absoluteString])
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

        let screenBounds = UIScreen.mainScreen().bounds
        self.containerViewWidthConstraint.constant = screenBounds.width
    }

    // MARK: Actions

    func share() {
        analyticsService.trackCustomEventWithName("Began Share", customAttributes: [AnalyticsServiceConstants.contentIDKey: issue.url.absoluteString,
            AnalyticsServiceConstants.contentNameKey: self.issue.title,
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
        let eventName = sender == self.titleButton ? "Tapped title on Issue" : "Tapped 'View Original' on Issue"
        analyticsService.trackCustomEventWithName(eventName, customAttributes: [AnalyticsServiceConstants.contentIDKey: issue.url.absoluteString])
        self.urlOpener.openURL(self.issue.url)
    }

    // MARK: Private

    // swiftlint:disable function_body_length
    private func setupConstraintsAndLayout() {
        let screenBounds = UIScreen.mainScreen().bounds

        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.contentSize.width = self.view.bounds.width
        self.scrollView.autoPinEdgesToSuperviewEdges()

        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Trailing)
        self.containerViewWidthConstraint = self.containerView.autoSetDimension(.Width, toSize: screenBounds.width)

        self.issueImageView.contentMode = .ScaleAspectFill
        self.issueImageView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)
        self.issueImageView.autoSetDimension(.Height, toSize: screenBounds.height / 3, relation: NSLayoutRelation.LessThanOrEqual)
        self.issueImageView.clipsToBounds = true

        NSLayoutConstraint.autoSetPriority(1000, forConstraints: { () -> Void in
            self.titleButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.issueImageView, withOffset: 25)
        })

        NSLayoutConstraint.autoSetPriority(500, forConstraints: { () -> Void in
            self.titleButton.autoPinEdgeToSuperviewEdge(.Top, withInset: 25)
        })

        let titleLabel = self.titleButton.titleLabel!
        titleLabel.numberOfLines = 0
        titleLabel.preferredMaxLayoutWidth = screenBounds.width - 8
        titleButton.contentHorizontalAlignment = .Left
        titleButton.autoPinEdgeToSuperviewMargin(.Left)
        titleButton.autoPinEdgeToSuperviewMargin(.Right)
        titleButton.layoutIfNeeded()
        titleButton.autoSetDimension(.Height, toSize: titleLabel.frame.height)

        bodyTextView.scrollEnabled = false
        bodyTextView.translatesAutoresizingMaskIntoConstraints = false
        bodyTextView.textContainerInset = UIEdgeInsetsZero
        bodyTextView.textContainer.lineFragmentPadding = 0
        bodyTextView.editable = false

        bodyTextView.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: self.titleButton, withOffset: 16)
        bodyTextView.autoPinEdgeToSuperviewMargin(.Left)
        bodyTextView.autoPinEdgeToSuperviewMargin(.Right)

        attributionLabel.numberOfLines = 0
        attributionLabel.textAlignment = .Center
        attributionLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: self.bodyTextView, withOffset: 16)
        attributionLabel.autoPinEdgeToSuperviewMargin(.Left)
        attributionLabel.autoPinEdgeToSuperviewMargin(.Right)

        viewOriginalButton.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: self.attributionLabel, withOffset: 16)
        viewOriginalButton.autoPinEdgesToSuperviewMarginsExcludingEdge(.Top)
        viewOriginalButton.autoSetDimension(.Height, toSize: 54)
    }
    // swiftlint:enable function_body_length

    private func applyThemeToViews() {
        self.view.backgroundColor = self.theme.defaultBackgroundColor()
        self.titleButton.titleLabel!.font = self.theme.issueTitleFont()
        self.titleButton.setTitleColor(self.theme.issueTitleColor(), forState: .Normal)
        self.bodyTextView.font = self.theme.issueBodyFont()
        self.bodyTextView.textColor = self.theme.issueBodyColor()
        self.attributionLabel.font = self.theme.attributionFont()
        self.attributionLabel.textColor = self.theme.attributionTextColor()
        self.viewOriginalButton.backgroundColor = self.theme.defaultButtonBackgroundColor()
        self.viewOriginalButton.setTitleColor(self.theme.defaultButtonTextColor(), forState: .Normal)
        self.viewOriginalButton.titleLabel!.font = self.theme.defaultButtonFont()
    }

    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(titleButton)
        containerView.addSubview(issueImageView)
        containerView.addSubview(bodyTextView)
        containerView.addSubview(attributionLabel)
        containerView.addSubview(viewOriginalButton)
    }
}
