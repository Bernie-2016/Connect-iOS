import UIKit
import CocoaMarkdown

class ActionAlertController: UIViewController {
    private let actionAlert: ActionAlert
    private let markdownConverter: MarkdownConverter
    private let urlOpener: URLOpener
    private let urlProvider: URLProvider
    private let analyticsService: AnalyticsService
    private let theme: Theme

    private let scrollView = UIScrollView.newAutoLayoutView()
    private let containerView = UIView.newAutoLayoutView()

    let dateLabel = UILabel.newAutoLayoutView()
    let titleLabel = UILabel.newAutoLayoutView()
    let bodyTextView = UITextView.newAutoLayoutView()
    let facebookShareButton = UIButton.newAutoLayoutView()
    let twitterShareButton = UIButton.newAutoLayoutView()
    let retweetButton = UIButton.newAutoLayoutView()

    private var containerViewWidthConstraint: NSLayoutConstraint!
    private var numberOfActiveShareButtons = 0

    init(actionAlert: ActionAlert, markdownConverter: MarkdownConverter, urlOpener: URLOpener, urlProvider: URLProvider, analyticsService: AnalyticsService, theme: Theme) {
        self.actionAlert = actionAlert
        self.markdownConverter = markdownConverter
        self.urlOpener = urlOpener
        self.urlProvider = urlProvider
        self.analyticsService = analyticsService
        self.theme = theme

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(dateLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(bodyTextView)
        containerView.addSubview(facebookShareButton)
        containerView.addSubview(twitterShareButton)
        containerView.addSubview(retweetButton)

        dateLabel.text = actionAlert.date
        titleLabel.text = actionAlert.title
        bodyTextView.attributedText = markdownConverter.convertToAttributedString(actionAlert.body)

        bodyTextView.editable = false
        bodyTextView.selectable = true

        facebookShareButton.hidden = actionAlert.targetURL == nil
        facebookShareButton.setImage(UIImage(named: "FacebookShare"), forState: .Normal)
        facebookShareButton.addTarget(self, action: "didTapFacebookShare", forControlEvents: .TouchUpInside)

        twitterShareButton.hidden = actionAlert.twitterURL == nil
        twitterShareButton.setImage(UIImage(named: "TwitterShare"), forState: .Normal)
        twitterShareButton.addTarget(self, action: "didTapTwitterShare", forControlEvents: .TouchUpInside)

        retweetButton.hidden = actionAlert.tweetID == nil
        retweetButton.setImage(UIImage(named: "Retweet"), forState: .Normal)
        retweetButton.addTarget(self, action: "didTapRetweet", forControlEvents: .TouchUpInside)

        numberOfActiveShareButtons = [facebookShareButton, twitterShareButton, retweetButton].filter { !$0.hidden }.count

        setupConstraints()
        applyTheme()
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

        let screenBounds = UIScreen.mainScreen().bounds
        containerViewWidthConstraint.constant = screenBounds.width
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            self.analyticsService.trackBackButtonTapOnScreen("Action Alert", customAttributes: [AnalyticsServiceConstants.contentIDKey: actionAlert.identifier])
        }
    }

    // MARK: Actions

    func didTapFacebookShare() {
        self.analyticsService.trackCustomEventWithName("Began Share", customAttributes: [
            AnalyticsServiceConstants.contentIDKey: actionAlert.identifier,
            AnalyticsServiceConstants.contentNameKey: actionAlert.title,
            AnalyticsServiceConstants.contentTypeKey: AnalyticsServiceContentType.ActionAlertFacebook.description
            ])

        let activityVC = UIActivityViewController(activityItems: [actionAlert.targetURL!], applicationActivities: nil)
        var excludedActivityTypes = [
            UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard,
            UIActivityTypeMail, UIActivityTypeMessage, UIActivityTypePostToFlickr, UIActivityTypePostToTencentWeibo,
            UIActivityTypePostToTwitter, UIActivityTypePostToVimeo, UIActivityTypePostToWeibo, UIActivityTypePrint,
            UIActivityTypeSaveToCameraRoll
        ]

        if #available(iOS 9.0, *) {
            excludedActivityTypes.append(UIActivityTypeOpenInIBooks)
        }

        activityVC.excludedActivityTypes = excludedActivityTypes
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            if error != nil {
                self.analyticsService.trackError(error!, context: "Failed to share Action Alert - Facebook")
            } else {
                if success == true {
                    self.analyticsService.trackShareWithActivityType(activity!, contentName: self.actionAlert.title, contentType: .ActionAlertFacebook, identifier: self.actionAlert.identifier)
                } else {
                    self.analyticsService.trackCustomEventWithName("Cancelled Share", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.actionAlert.identifier,
                        AnalyticsServiceConstants.contentNameKey: self.actionAlert.title,
                        AnalyticsServiceConstants.contentTypeKey: AnalyticsServiceContentType.ActionAlertFacebook.description
                        ])
                }
            }
        }
        presentViewController(activityVC, animated: true, completion: nil)
    }

    func didTapTwitterShare() {
        self.analyticsService.trackCustomEventWithName("Began Share", customAttributes: [
            AnalyticsServiceConstants.contentIDKey: actionAlert.identifier,
            AnalyticsServiceConstants.contentNameKey: actionAlert.title,
            AnalyticsServiceConstants.contentTypeKey: AnalyticsServiceContentType.ActionAlertTwitter.description
            ])

        let url = urlProvider.twitterShareURL(actionAlert.twitterURL!)
        urlOpener.openURL(url)
    }

    func didTapRetweet() {
        self.analyticsService.trackCustomEventWithName("Began Share", customAttributes: [
            AnalyticsServiceConstants.contentIDKey: actionAlert.identifier,
            AnalyticsServiceConstants.contentNameKey: actionAlert.title,
            AnalyticsServiceConstants.contentTypeKey: AnalyticsServiceContentType.ActionAlertRetweet.description
            ])

        let url = urlProvider.retweetURL(actionAlert.tweetID!)
        urlOpener.openURL(url)
    }
}

// MARK: Private

extension ActionAlertController {
    private func setupConstraints() {
        let defaultHorizontalMargin: CGFloat = 15
        let defaultVerticalMargin: CGFloat = 21

        let screenBounds = UIScreen.mainScreen().bounds

        scrollView.contentSize.width = self.view.bounds.width
        scrollView.autoPinEdgesToSuperviewEdges()

        containerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Trailing)
        containerViewWidthConstraint = containerView.autoSetDimension(.Width, toSize: screenBounds.width)

        dateLabel.numberOfLines = 0
        dateLabel.preferredMaxLayoutWidth = screenBounds.width - defaultHorizontalMargin
        dateLabel.textAlignment = .Left
        dateLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: defaultVerticalMargin)
        dateLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        dateLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin)
        dateLabel.layoutIfNeeded()

        titleLabel.numberOfLines = 0
        titleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: dateLabel, withOffset: 5)
        titleLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        titleLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin)

        bodyTextView.scrollEnabled = false
        bodyTextView.textContainer.lineFragmentPadding = 0
        bodyTextView.editable = false

        bodyTextView.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 10)
        bodyTextView.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        bodyTextView.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin)

        facebookShareButton.autoSetDimension(.Height, toSize: 40)
        facebookShareButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: bodyTextView, withOffset: twitterShareButton.hidden ? 0 : 18)
        facebookShareButton.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        facebookShareButton.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin)
        facebookShareButton.autoPinEdgeToSuperviewEdge(.Bottom, withInset: defaultVerticalMargin, relation: .GreaterThanOrEqual)

        twitterShareButton.autoSetDimension(.Height, toSize: 40)
        twitterShareButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: facebookShareButton, withOffset: twitterShareButton.hidden ? 0 : 18)
        twitterShareButton.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        twitterShareButton.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin)

        retweetButton.autoSetDimension(.Height, toSize: 40)
        retweetButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: twitterShareButton, withOffset: retweetButton.hidden ? 0 : 18)
        retweetButton.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultHorizontalMargin)
        retweetButton.autoPinEdgeToSuperviewEdge(.Right, withInset: defaultHorizontalMargin)
        retweetButton.autoPinEdgeToSuperviewEdge(.Bottom, withInset: defaultVerticalMargin, relation: .GreaterThanOrEqual)
    }

    private func applyTheme() {
        view.backgroundColor = theme.contentBackgroundColor()
        dateLabel.font = theme.actionAlertDateFont()
        dateLabel.textColor = theme.actionAlertDateTextColor()
        titleLabel.font = theme.actionAlertTitleFont()
        titleLabel.textColor = theme.actionAlertTitleTextColor()

        let buttonBorderWidth = CGFloat(1.0)
        let buttonCornerRadius = CGFloat(3.0)

        facebookShareButton.layer.borderColor = theme.defaultButtonBorderColor().CGColor
        facebookShareButton.layer.borderWidth = buttonBorderWidth
        facebookShareButton.layer.cornerRadius = buttonCornerRadius

        twitterShareButton.layer.borderWidth = buttonBorderWidth
        twitterShareButton.layer.borderColor = theme.defaultButtonBorderColor().CGColor
        twitterShareButton.layer.cornerRadius = buttonCornerRadius

        retweetButton.layer.borderWidth = buttonBorderWidth
        retweetButton.layer.borderColor = theme.defaultButtonBorderColor().CGColor
        retweetButton.layer.cornerRadius = buttonCornerRadius
    }
}
