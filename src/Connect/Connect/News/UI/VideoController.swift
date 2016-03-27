import UIKit
import XCDYouTubeKit
import AMScrollingNavbar

// swiftlint:disable type_body_length
class VideoController: UIViewController {
    let video: Video
    let timeIntervalFormatter: TimeIntervalFormatter
    let urlProvider: URLProvider
    let urlOpener: URLOpener
    let analyticsService: AnalyticsService
    let theme: Theme

    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private var containerViewWidthConstraint: NSLayoutConstraint!

    let videoView = UIView()
    var videoController: XCDYouTubeVideoPlayerViewController!
    let titleLabel = UILabel()
    let dateLabel = UILabel()
    let descriptionTextView = UITextView()

    init(video: Video,
        timeIntervalFormatter: TimeIntervalFormatter,
        urlProvider: URLProvider,
        urlOpener: URLOpener,
        analyticsService: AnalyticsService,
        theme: Theme) {
            self.video = video
            self.timeIntervalFormatter = timeIntervalFormatter
            self.analyticsService = analyticsService
            self.urlProvider = urlProvider
            self.urlOpener = urlOpener

            self.theme = theme

            super.init(nibName: nil, bundle: nil)
    }

    // MARK: UIViewController

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "navBarShareButton"), style: .Plain, target: self, action: #selector(VideoController.share))

        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(videoView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(descriptionTextView)

        scrollView.delegate = self

        titleLabel.text = video.title
        dateLabel.text = timeIntervalFormatter.humanDaysSinceDate(video.date)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = theme.defaultBodyTextLineHeight()
        paragraphStyle.maximumLineHeight = theme.defaultBodyTextLineHeight()
        paragraphStyle.minimumLineHeight = theme.defaultBodyTextLineHeight()

        let attributes = [ NSParagraphStyleAttributeName: paragraphStyle ]
        let attributedDescription = NSAttributedString(string: video.description, attributes: attributes)
        descriptionTextView.attributedText = attributedDescription

        videoController = XCDYouTubeVideoPlayerViewController(videoIdentifier: video.identifier)
        videoController.moviePlayer.prepareToPlay()
        videoController.moviePlayer.shouldAutoplay = true
        videoController.presentInView(videoView)

        applyThemeToViews()
        setupConstraints()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(scrollView, delay: 50.0)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        if !videoController.moviePlayer.fullscreen { videoController.moviePlayer.stop() }
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            analyticsService.trackBackButtonTapOnScreen("Video", customAttributes: [AnalyticsServiceConstants.contentIDKey: video.identifier])
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
            AnalyticsServiceConstants.contentIDKey: video.identifier,
            AnalyticsServiceConstants.contentNameKey: video.title,
            AnalyticsServiceConstants.contentTypeKey: AnalyticsServiceContentType.Video.description
            ])
        let activityVC = UIActivityViewController(activityItems: [urlProvider.youtubeVideoURL(video.identifier)], applicationActivities: nil)

        activityVC.completionWithItemsHandler = { activity, success, items, error in
            if error != nil {
                self.analyticsService.trackError(error!, context: "Failed to share Video")
            } else {
                if success == true {
                    self.analyticsService.trackShareWithActivityType(activity!, contentName: self.video.title, contentType: .Video, identifier: self.video.identifier)
                } else {
                    self.analyticsService.trackCustomEventWithName("Cancelled Share", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.video.identifier,
                        AnalyticsServiceConstants.contentNameKey: self.video.title,
                        AnalyticsServiceConstants.contentTypeKey: AnalyticsServiceContentType.Video.description
                        ])
                }
            }
        }

        presentViewController(activityVC, animated: true, completion: nil)
    }

    // MARK: Private

    private func applyThemeToViews() {
        view.backgroundColor = theme.contentBackgroundColor()
        dateLabel.textColor = theme.videoDateColor()
        dateLabel.font = theme.videoDateFont()
        titleLabel.textColor = theme.videoTitleColor()
        titleLabel.font = theme.videoTitleFont()
        descriptionTextView.textColor = theme.videoDescriptionColor()
        descriptionTextView.font = theme.videoDescriptionFont()
    }

    private func setupConstraints() {
        let screenBounds = UIScreen.mainScreen().bounds

        videoView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)
        scrollView.contentSize.width = self.view.bounds.width
        scrollView.autoPinEdgesToSuperviewEdges()

        containerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Trailing)
        containerViewWidthConstraint = self.containerView.autoSetDimension(.Width, toSize: screenBounds.width)

        videoView.contentMode = .ScaleAspectFill
        videoView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)
        videoView.autoSetDimension(.Height, toSize: screenBounds.height / 3)
        videoView.clipsToBounds = true

        setupTextContentConstraints()
    }

    private func setupTextContentConstraints() {
        let screenBounds = UIScreen.mainScreen().bounds

        titleLabel.numberOfLines = 0
        titleLabel.preferredMaxLayoutWidth = screenBounds.width - 8
        titleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: videoView, withOffset: 25)
        titleLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        titleLabel.autoPinEdgeToSuperviewMargin(.Trailing)
        titleLabel.layoutIfNeeded()
        titleLabel.autoSetDimension(.Height, toSize: titleLabel.frame.height)

        dateLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 5)
        dateLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        dateLabel.autoPinEdgeToSuperviewMargin(.Trailing)
        dateLabel.autoSetDimension(.Height, toSize: 20)

        descriptionTextView.scrollEnabled = false
        descriptionTextView.textContainerInset = UIEdgeInsetsZero
        descriptionTextView.textContainer.lineFragmentPadding = 0
        descriptionTextView.editable = false

        descriptionTextView.autoPinEdge(.Top, toEdge: .Bottom, ofView: dateLabel, withOffset: 11)
        descriptionTextView.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        descriptionTextView.autoPinEdgeToSuperviewMargin(.Right)
        descriptionTextView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 15)
    }
}

extension VideoController: UIScrollViewDelegate {
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.showNavbar(animated: true)
        }
        return true
    }
}
// swiftlint:enable type_body_length
