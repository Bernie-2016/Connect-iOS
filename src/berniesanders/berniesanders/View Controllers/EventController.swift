import UIKit
import CoreLocation
import MapKit

public class EventController : UIViewController {
    public let event : Event!
    public let eventPresenter: EventPresenter!
    public let theme : Theme!
    
    let containerView = UIView.newAutoLayoutView()
    let scrollView = UIScrollView.newAutoLayoutView()
    public let mapView = MKMapView.newAutoLayoutView()
    public let nameLabel = UILabel.newAutoLayoutView()
    public let dateIconImageView = UIImageView.newAutoLayoutView()
    public let dateLabel = UILabel.newAutoLayoutView()
    public let attendeesIconImageView = UIImageView.newAutoLayoutView()
    public let attendeesLabel = UILabel.newAutoLayoutView()
    public let addressIconImageView = UIImageView.newAutoLayoutView()
    public let addressLabel = UILabel.newAutoLayoutView()
    public let descriptionHeadingLabel = UILabel.newAutoLayoutView()
    public let descriptionLabel = UILabel.newAutoLayoutView()
    
    public init(
        event: Event,
        eventPresenter: EventPresenter,
        theme: Theme) {            
            self.event = event
            self.eventPresenter = eventPresenter
            self.theme = theme
            
            super.init(nibName: nil, bundle: nil)
            
            self.hidesBottomBarWhenPushed = true // TODO: test this when initialized, not when viewDidLoad
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let eventCoordinate = event.location.coordinate
        let regionRadius: CLLocationDistance = 800
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(eventCoordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        let eventPin = MKPointAnnotation()
        eventPin.coordinate = eventCoordinate
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.addAnnotation(eventPin)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "share")
        navigationItem.title = NSLocalizedString("Event_navigationTitle", comment: "")
        
        applyTheme()
        
        nameLabel.text = event.name
        dateIconImageView.image = UIImage(named: "eventCalendar")
        dateIconImageView.contentMode = .ScaleAspectFit
        dateLabel.text = eventPresenter.presentDateForEvent(event)
        addressIconImageView.image = UIImage(named: "eventPhone")
        addressIconImageView.contentMode = .ScaleAspectFit
        addressLabel.text = eventPresenter.presentAddressForEvent(event)
        attendeesIconImageView.image = UIImage(named: "eventPin")
        attendeesIconImageView.contentMode = .ScaleAspectFit
        attendeesLabel.text = eventPresenter.presentAttendeesForEvent(event)
        descriptionHeadingLabel.text = NSLocalizedString("Event_descriptionHeading", comment: "")
        descriptionLabel.text = event.description
        
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(mapView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(dateIconImageView)
        containerView.addSubview(dateLabel)
        containerView.addSubview(attendeesIconImageView)
        containerView.addSubview(attendeesLabel)
        containerView.addSubview(addressIconImageView)
        containerView.addSubview(addressLabel)
        containerView.addSubview(descriptionHeadingLabel)
        containerView.addSubview(descriptionLabel)
        
        setupConstraints()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Actions
    
    func share() {
        let activityVC = UIActivityViewController(activityItems: [event.URL], applicationActivities: nil)
        presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func applyTheme() {
        view.backgroundColor = theme.defaultBackgroundColor()
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
        
        nameLabel.numberOfLines = 0
        nameLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: mapView, withOffset: 12)
        nameLabel.autoPinEdgeToSuperviewMargin(.Left)
        nameLabel.autoPinEdgeToSuperviewMargin(.Right)
        
        dateIconImageView.autoPinEdgeToSuperviewMargin(.Left)
        dateIconImageView.autoSetDimension(.Width, toSize: 20)
        dateIconImageView.autoAlignAxis(.Horizontal, toSameAxisOfView: dateLabel)
        dateLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: nameLabel, withOffset: 20)
        dateLabel.autoPinEdge(.Left, toEdge: .Right, ofView: dateIconImageView, withOffset: 12)
        dateLabel.autoPinEdgeToSuperviewMargin(.Right)
        
        attendeesIconImageView.autoPinEdgeToSuperviewMargin(.Left)
        attendeesIconImageView.autoSetDimension(.Width, toSize: 20)
        attendeesIconImageView.autoAlignAxis(.Horizontal, toSameAxisOfView: attendeesLabel)
        attendeesLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: dateLabel, withOffset: 16)
        attendeesLabel.autoPinEdge(.Left, toEdge: .Right, ofView: attendeesIconImageView, withOffset: 12)
        attendeesLabel.autoPinEdgeToSuperviewMargin(.Right)
        
        addressIconImageView.autoPinEdgeToSuperviewMargin(.Left)
        addressIconImageView.autoSetDimension(.Width, toSize: 20)
        addressIconImageView.autoAlignAxis(.Horizontal, toSameAxisOfView: addressLabel)
        addressLabel.numberOfLines = 0
        addressLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: attendeesLabel, withOffset: 12)
        addressLabel.autoPinEdge(.Left, toEdge: .Right, ofView: addressIconImageView, withOffset: 12)
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
}
