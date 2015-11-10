import UIKit
import CoreLocation
import MapKit

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
    private let scrollView = UIScrollView.newAutoLayoutView()
    let mapView = MKMapView.newAutoLayoutView()
    let rsvpButton = UIButton.newAutoLayoutView()
    let directionsButton = UIButton.newAutoLayoutView()
    let nameLabel = UILabel.newAutoLayoutView()
    let dateLabel = UILabel.newAutoLayoutView()
    let attendeesLabel = UILabel.newAutoLayoutView()
    let addressLabel = UILabel.newAutoLayoutView()
    let descriptionHeadingLabel = UILabel.newAutoLayoutView()
    let descriptionLabel = UILabel.newAutoLayoutView()

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

        let backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Event_backButtonTitle", comment: ""),
            style: UIBarButtonItemStyle.Plain,
            target: nil, action: nil)

        navigationItem.backBarButtonItem = backBarButtonItem

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Global_share", comment: ""), style: .Plain, target: self, action: "share")
        navigationItem.title = NSLocalizedString("Event_navigationTitle", comment: "")

        directionsButton.setTitle(NSLocalizedString("Event_directionsButtonTitle", comment: ""), forState: .Normal)
        directionsButton.addTarget(self, action: "didTapDirections", forControlEvents: .TouchUpInside)

        rsvpButton.setTitle(NSLocalizedString("Event_rsvpButtonTitle", comment: ""), forState: .Normal)
        rsvpButton.addTarget(self, action: "didTapRSVP", forControlEvents: .TouchUpInside)

        setupLabels()
        applyTheme()
        addSubviews()
        setupConstraints()
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        self.analyticsService.trackCustomEventWithName("Tapped 'Back' on Event", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.event.url.absoluteString])
    }

    // MARK: Actions

    func share() {
        self.analyticsService.trackCustomEventWithName("Tapped 'Share' on Event", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.event.url.absoluteString])

        let activityVC = UIActivityViewController(activityItems: [event.url], applicationActivities: nil)
        presentViewController(activityVC, animated: true, completion: nil)
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            if error != nil {
                self.analyticsService.trackError(error!, context: "Failed to share Event")
            } else {
                if success == true {
                    self.analyticsService.trackShareWithActivityType(activity!, contentName: self.event.name, contentType: .Event, id: self.event.url.absoluteString)
                } else {
                    self.analyticsService.trackCustomEventWithName("Cancelled share of Event", customAttributes: [AnalyticsServiceConstants.contentIDKey: self.event.url.absoluteString])
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
        view.backgroundColor = theme.defaultBackgroundColor()
        rsvpButton.backgroundColor = theme.eventRSVPButtonBackgroundColor()
        rsvpButton.setTitleColor(theme.eventButtonTextColor(), forState: .Normal)
        rsvpButton.titleLabel!.font = theme.eventDirectionsButtonFont()

        directionsButton.backgroundColor = theme.eventDirectionsButtonBackgroundColor()
        directionsButton.setTitleColor(theme.eventButtonTextColor(), forState: .Normal)
        directionsButton.titleLabel!.font = theme.eventDirectionsButtonFont()
        nameLabel.textColor = theme.eventNameColor()
        nameLabel.font = theme.eventNameFont()
        dateLabel.textColor = theme.eventStartDateColor()
        dateLabel.font = theme.eventStartDateFont()
        attendeesLabel.textColor = theme.eventAttendeesColor()
        attendeesLabel.font = theme.eventAttendeesFont()
        addressLabel.textColor = theme.eventAddressColor()
        addressLabel.font = theme.eventAddressFont()
        descriptionHeadingLabel.textColor = theme.eventDescriptionHeadingColor()
        descriptionHeadingLabel.font = theme.eventDescriptionHeadingFont()
        descriptionLabel.textColor = theme.eventDescriptionColor()
        descriptionLabel.font = theme.eventDescriptionFont()
    }

    func setupLabels() {
        nameLabel.text = event.name
        dateLabel.text = eventPresenter.presentDateForEvent(event)
        addressLabel.text = eventPresenter.presentAddressForEvent(event)
        attendeesLabel.text = eventPresenter.presentAttendeesForEvent(event)
        descriptionHeadingLabel.text = NSLocalizedString("Event_descriptionHeading", comment: "")
        descriptionLabel.text = event.description
    }

    func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(rsvpButton)
        containerView.addSubview(directionsButton)
        containerView.addSubview(mapView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(attendeesLabel)
        containerView.addSubview(addressLabel)
        containerView.addSubview(descriptionHeadingLabel)
        containerView.addSubview(descriptionLabel)
    }

    // swiftlint:disable function_body_length
    func setupConstraints() {
        let screenBounds = UIScreen.mainScreen().bounds

        scrollView.contentSize.width = self.view.bounds.width
        scrollView.autoPinEdgesToSuperviewEdges()

        containerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Trailing)
        containerView.autoSetDimension(.Width, toSize: screenBounds.width)

        mapView.autoPinEdgeToSuperviewEdge(.Top)
        mapView.autoPinEdgeToSuperviewEdge(.Left)
        mapView.autoPinEdgeToSuperviewEdge(.Right)
        mapView.autoSetDimension(.Height, toSize: self.view.bounds.height / 3)

        rsvpButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: mapView)
        rsvpButton.autoPinEdgeToSuperviewEdge(.Left)
        rsvpButton.autoSetDimension(.Height, toSize: 55)
        rsvpButton.autoSetDimension(.Width, toSize: screenBounds.width / 2)

        directionsButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: mapView)
        directionsButton.autoPinEdge(.Left, toEdge: .Right, ofView: rsvpButton)
        directionsButton.autoPinEdgeToSuperviewEdge(.Right)
        directionsButton.autoSetDimension(.Height, toSize: 55)

        nameLabel.numberOfLines = 0
        nameLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: directionsButton, withOffset: 12)
        nameLabel.autoPinEdgeToSuperviewMargin(.Left)
        nameLabel.autoPinEdgeToSuperviewMargin(.Right)

        dateLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: nameLabel, withOffset: 20)
        dateLabel.autoPinEdgeToSuperviewMargin(.Left)
        dateLabel.autoPinEdgeToSuperviewMargin(.Right)

        attendeesLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: dateLabel, withOffset: 16)
        attendeesLabel.autoPinEdgeToSuperviewMargin(.Left)
        attendeesLabel.autoPinEdgeToSuperviewMargin(.Right)

        addressLabel.numberOfLines = 0
        addressLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: attendeesLabel, withOffset: 12)
        addressLabel.autoPinEdgeToSuperviewMargin(.Left)
        addressLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 12)

        descriptionHeadingLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: addressLabel, withOffset: 16)
        descriptionHeadingLabel.autoPinEdgeToSuperviewMargin(.Left)
        descriptionHeadingLabel.autoPinEdgeToSuperviewMargin(.Right)

        descriptionLabel.numberOfLines = 0
        descriptionLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: descriptionHeadingLabel, withOffset: 8)
        descriptionLabel.autoPinEdgeToSuperviewMargin(.Left)
        descriptionLabel.autoPinEdgeToSuperviewMargin(.Right)
        descriptionLabel.autoPinEdgeToSuperviewMargin(.Bottom)
    }
    // swiftlint:enable function_body_length
}
// swiftlint:enable type_body_length
