import UIKit
import XCDYouTubeKit

class VideoController: UIViewController {
    let video: Video
    let imageRepository: ImageRepository
    let timeIntervalFormatter: TimeIntervalFormatter
    let urlProvider: URLProvider
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
        imageRepository: ImageRepository,
        timeIntervalFormatter: TimeIntervalFormatter,
        urlProvider: URLProvider,
        analyticsService: AnalyticsService,
        theme: Theme) {
            self.video = video
            self.imageRepository = imageRepository
            self.timeIntervalFormatter = timeIntervalFormatter
            self.analyticsService = analyticsService
            self.urlProvider = urlProvider
            self.theme = theme

            super.init(nibName: nil, bundle: nil)
    }

    // MARK: UIViewController

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Global_share", comment: ""), style: .Plain, target: self, action: "share")

        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(videoView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(descriptionTextView)

        titleLabel.text = video.title
        dateLabel.text = timeIntervalFormatter.humanDaysSinceDate(video.date)
        print(video.description)
        descriptionTextView.text = video.description

        videoController = XCDYouTubeVideoPlayerViewController(videoIdentifier: video.identifier)
        videoController.moviePlayer.prepareToPlay()
        videoController.moviePlayer.shouldAutoplay = true
        videoController.presentInView(videoView)

        applyThemeToViews()
        setupConstraints()
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
        view.backgroundColor = theme.defaultBackgroundColor()
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

        descriptionTextView.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.dateLabel, withOffset: 14)
        descriptionTextView.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        descriptionTextView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 20)
        descriptionTextView.autoPinEdgeToSuperviewMargin(.Right)
    }
}
