import UIKit
import CoreLocation
import MapKit
import AMScrollingNavbar

// swiftlint:disable type_body_length
class EventController: UIViewController {
    let event: Event
    let eventPresenter: EventPresenter
    let eventRSVPControllerProvider: EventRSVPControllerProvider
    let urlProvider: URLProvider
    let urlOpener: URLOpener
    let analyticsService: AnalyticsService
    let theme: Theme

    private let containerView = UIView.newAutoLayoutView()
    private var containerViewWidthConstraint: NSLayoutConstraint!
    private let scrollView = UIScrollView.newAutoLayoutView()
    let mapView = MKMapView.newAutoLayoutView()
    let dateLabel = UILabel.newAutoLayoutView()
    let nameLabel = UILabel.newAutoLayoutView()
    let directionsButton = DisclosureButton.newAutoLayoutView()
    let descriptionHeadingLabel = UILabel.newAutoLayoutView()
    let descriptionLabel = UILabel.newAutoLayoutView()
    let rsvpButton = UIButton.newAutoLayoutView()

    private let topSectionSpacer = UIView.newAutoLayoutView()
    private let bottomSectionSpacer = UIView.newAutoLayoutView()
    private let bottomRubberBandingArea = UIView.newAutoLayoutView()

    init(
        event: Event,
        eventPresenter: EventPresenter,
        eventRSVPControllerProvider: EventRSVPControllerProvider,
        urlProvider: URLProvider,
        urlOpener: URLOpener,
        analyticsService: AnalyticsService,
        theme: Theme) {
            self.event = event
            self.eventPresenter = eventPresenter
            self.eventRSVPControllerProvider = eventRSVPControllerProvider
            self.urlProvider = urlProvider
            self.urlOpener = urlOpener
            self.analyticsService = analyticsService
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

        let eventCoordinate = event.location.coordinate
        let regionRadius: CLLocationDistance = 800
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(eventCoordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        let eventPin = MKPointAnnotation()
        eventPin.coordinate = eventCoordinate
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.addAnnotation(eventPin)

        let backBarButtonItem = UIBarButtonItem(title: "",
                                                style: .Plain,
                                                target: nil, action: nil)

        navigationItem.backBarButtonItem = backBarButtonItem


        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "navBarShareButton"), style: .Plain, target: self, action: #selector(EventController.share))
        navigationItem.title = event.eventTypeName

        directionsButton.addTarget(self, action: #selector(EventController.didTapDirections), forControlEvents: .TouchUpInside)
        rsvpButton.addTarget(self, action: #selector(EventController.didTapRSVP), forControlEvents: .TouchUpInside)

        scrollView.delegate = self

        setupLabels()
        applyTheme()
        addSubviews()
        setupConstraints()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: animated)

        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(scrollView, delay: 50.0)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.showNavbar(animated: true)
        }
    }


    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            self.analyticsService.trackBackButtonTapOnScreen("Event", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.event.url.absoluteString])
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
            AnalyticsServiceConstants.contentIDKey: self.event.url.absoluteString,
            AnalyticsServiceConstants.contentNameKey: self.event.name,
            AnalyticsServiceConstants.contentTypeKey: AnalyticsServiceContentType.Event.description
            ])

        let activityVC = UIActivityViewController(activityItems: [event.url], applicationActivities: nil)
        presentViewController(activityVC, animated: true, completion: nil)
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            if error != nil {
                self.analyticsService.trackError(error!, context: "Failed to share Event")
            } else {
                if success == true {
                    self.analyticsService.trackShareWithActivityType(activity!, contentName: self.event.name, contentType: .Event, identifier: self.event.url.absoluteString)
                } else {
                    self.analyticsService.trackCustomEventWithName("Cancelled Share", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.event.url.absoluteString,
                        AnalyticsServiceConstants.contentNameKey: self.event.name,
                        AnalyticsServiceConstants.contentTypeKey: AnalyticsServiceContentType.Event.description
                        ])
                }
            }
        }
    }

    func didTapDirections() {
        self.analyticsService.trackCustomEventWithName("Tapped 'Directions' on Event", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.event.url.absoluteString])
        self.urlOpener.openURL(self.urlProvider.mapsURLForEvent(self.event))
    }

    func didTapRSVP() {
        self.analyticsService.trackCustomEventWithName("Tapped 'RSVP' on Event", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.event.url.absoluteString])
        let rsvpController = self.eventRSVPControllerProvider.provideControllerWithEvent(event)
        navigationController?.pushViewController(rsvpController, animated: true)
    }

    // MARK: Private

    func applyTheme() {
        view.backgroundColor = theme.eventBackgroundColor()
        containerView.backgroundColor = UIColor.whiteColor()

        dateLabel.textColor = theme.eventStartDateColor()
        dateLabel.font = theme.eventStartDateFont()
        nameLabel.textColor = theme.eventNameColor()
        nameLabel.font = theme.eventNameFont()

        topSectionSpacer.backgroundColor = theme.eventBackgroundColor()

        directionsButton.backgroundColor = theme.eventDirectionsButtonBackgroundColor()
        directionsButton.title.textColor = theme.eventDirectionsButtonTextColor()
        directionsButton.title.font = theme.eventDirectionsButtonFont()
        directionsButton.subTitle.textColor = theme.eventAddressColor()
        directionsButton.subTitle.font = theme.eventAddressFont()
        directionsButton.disclosureView.color = theme.defaultDisclosureColor()

        bottomSectionSpacer.backgroundColor = theme.eventBackgroundColor()

        descriptionHeadingLabel.textColor = theme.eventDescriptionHeadingColor()
        descriptionHeadingLabel.font = theme.eventDescriptionHeadingFont()
        descriptionLabel.textColor = theme.eventDescriptionColor()
        descriptionLabel.font = theme.eventDescriptionFont()

        bottomRubberBandingArea.backgroundColor = theme.eventBackgroundColor()

        rsvpButton.backgroundColor = theme.fullWidthButtonBackgroundColor()
        rsvpButton.setTitleColor(theme.fullWidthRSVPButtonTextColor(), forState: .Normal)
        rsvpButton.titleLabel!.font = theme.fullWidthRSVPButtonFont()
        rsvpButton.titleLabel!.numberOfLines = 1
        rsvpButton.titleLabel!.adjustsFontSizeToFitWidth = true
        rsvpButton.titleLabel!.lineBreakMode = .ByClipping
    }

    func setupLabels() {
        nameLabel.text = event.name
        dateLabel.text = eventPresenter.presentDateTimeForEvent(event)
        directionsButton.title.text = NSLocalizedString("Event_directionsButtonTitle", comment: "")
        directionsButton.subTitle.text = eventPresenter.presentAddressForEvent(event)
        descriptionHeadingLabel.text = NSLocalizedString("Event_descriptionHeading", comment: "")
        descriptionLabel.text = event.description
        rsvpButton.setTitle(self.eventPresenter.presentRSVPButtonTextForEvent(event), forState: .Normal)
    }

    func addSubviews() {
        view.addSubview(scrollView)
        view.addSubview(rsvpButton)
        scrollView.addSubview(containerView)
        containerView.addSubview(mapView)
        containerView.addSubview(dateLabel)
        containerView.addSubview(nameLabel)

        containerView.addSubview(topSectionSpacer)
        containerView.addSubview(directionsButton)
        containerView.addSubview(bottomSectionSpacer)
        containerView.addSubview(descriptionHeadingLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(bottomRubberBandingArea)
    }

    // swiftlint:disable function_body_length
    func setupConstraints() {
        let screenBounds = UIScreen.mainScreen().bounds

        scrollView.contentSize.width = view.bounds.width
        scrollView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)

        rsvpButton.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Top)
        rsvpButton.autoSetDimension(.Height, toSize: 54)

        containerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Trailing)
        containerViewWidthConstraint = containerView.autoSetDimension(.Width, toSize: screenBounds.width)

        mapView.autoPinEdgeToSuperviewEdge(.Top)
        mapView.autoPinEdgeToSuperviewEdge(.Left)
        mapView.autoPinEdgeToSuperviewEdge(.Right)
        mapView.autoSetDimension(.Height, toSize: view.bounds.height / 3)

        dateLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: mapView, withOffset: 15)
        dateLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        dateLabel.autoPinEdgeToSuperviewEdge(.Right)

        nameLabel.numberOfLines = 0
        nameLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: dateLabel, withOffset: 6)
        nameLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        nameLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 20)

        topSectionSpacer.autoPinEdge(.Top, toEdge: .Bottom, ofView: nameLabel, withOffset: 15)
        topSectionSpacer.autoPinEdgeToSuperviewEdge(.Left)
        topSectionSpacer.autoPinEdgeToSuperviewEdge(.Right)
        topSectionSpacer.autoSetDimension(.Height, toSize: 11)

        directionsButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: topSectionSpacer)
        directionsButton.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        directionsButton.autoPinEdgeToSuperviewEdge(.Right)
        directionsButton.autoSetDimension(.Height, toSize: 54)
        directionsButton.subTitle.numberOfLines = 0

        bottomSectionSpacer.autoPinEdge(.Top, toEdge: .Bottom, ofView: directionsButton, withOffset: 15)
        bottomSectionSpacer.autoPinEdgeToSuperviewEdge(.Left)
        bottomSectionSpacer.autoPinEdgeToSuperviewEdge(.Right)
        bottomSectionSpacer.autoSetDimension(.Height, toSize: 11)

        descriptionHeadingLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: bottomSectionSpacer, withOffset: 15)
        descriptionHeadingLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        descriptionHeadingLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 20)

        descriptionLabel.numberOfLines = 0
        descriptionLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: descriptionHeadingLabel, withOffset: 6)
        descriptionLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        descriptionLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 20)

        bottomRubberBandingArea.autoPinEdge(.Top, toEdge: .Bottom, ofView: descriptionLabel, withOffset: 15)
        bottomRubberBandingArea.autoSetDimension(.Height, toSize: 54)
        bottomRubberBandingArea.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Top)
    }
    // swiftlint:enable function_body_length
}

extension EventController: UIScrollViewDelegate {
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.showNavbar(animated: true)
        }
        return true
    }
}
// swiftlint:enable type_body_length
