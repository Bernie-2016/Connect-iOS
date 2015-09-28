import UIKit
import PureLayout
import QuartzCore

public class EventsController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    public let eventRepository: EventRepository!
    public let eventPresenter: EventPresenter!
    public let settingsController: SettingsController!
    let eventControllerProvider: EventControllerProvider
    public let theme: Theme!
    
    public let zipCodeTextField = UITextField.newAutoLayoutView()
    public let eventSearchButton = UIButton.newAutoLayoutView()
    public let resultsTableView = UITableView.newAutoLayoutView()
    public let noResultsLabel = UILabel.newAutoLayoutView()
    public let loadingActivityIndicatorView = UIActivityIndicatorView.newAutoLayoutView()
    
    var events: Array<Event>!
    
    public init(eventRepository: EventRepository,
        eventPresenter: EventPresenter,
        settingsController: SettingsController,
        eventControllerProvider: EventControllerProvider,
        theme: Theme) {
        
        self.eventRepository = eventRepository
        self.eventPresenter = eventPresenter
        self.settingsController = settingsController
        self.eventControllerProvider = eventControllerProvider
        self.theme = theme
        
        self.events = []
        
        super.init(nibName: nil, bundle: nil)
            
        self.tabBarItem.setTitlePositionAdjustment(UIOffsetMake(0, -4))
        self.tabBarItem.image = UIImage(named: "eventsTabBarIconInactive")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBarItem.selectedImage = UIImage(named: "eventsTabBarIcon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
        let activeTabBarTextAttributes = [NSFontAttributeName: theme.tabBarFont(), NSForegroundColorAttributeName: theme.tabBarActiveTextColor()]
        let inactiveTabBarTextAttributes = [NSFontAttributeName: theme.tabBarFont(), NSForegroundColorAttributeName: theme.tabBarInactiveTextColor()]
        
        self.tabBarItem.setTitleTextAttributes(inactiveTabBarTextAttributes, forState: .Normal)
        self.tabBarItem.setTitleTextAttributes(activeTabBarTextAttributes, forState: .Selected)
        
        self.title = NSLocalizedString("Events_tabBarTitle", comment: "")
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Events_navigationTitle", comment: "")
        let settingsIcon = UIImage(named: "settingsIcon")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: settingsIcon, style: .Plain, target: self, action: "didTapSettings")
        let backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Events_backButtonTitle", comment: ""),
            style: UIBarButtonItemStyle.Plain,
            target: nil, action: nil)
        
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        self.edgesForExtendedLayout = .None
        self.resultsTableView.dataSource = self
        self.resultsTableView.delegate = self // TODO: TEST ME!
        self.resultsTableView.registerClass(EventListTableViewCell.self, forCellReuseIdentifier: "eventCell")
        
        setNeedsStatusBarAppearanceUpdate()
        
        view.addSubview(zipCodeTextField)
        view.addSubview(eventSearchButton)
        view.addSubview(resultsTableView)
        view.addSubview(noResultsLabel)
        view.addSubview(loadingActivityIndicatorView)
        
        eventSearchButton.setTitle(NSLocalizedString("Events_eventSearchButtonTitle", comment: ""), forState: .Normal)
        eventSearchButton.addTarget(self, action: "didTapSearch:", forControlEvents: .TouchUpInside)
        eventSearchButton.backgroundColor = self.theme.eventsGoButtonBackgroundColor()
        eventSearchButton.titleLabel!.font = self.theme.eventsGoButtonFont()
        eventSearchButton.titleLabel!.textColor = self.theme.eventsGoButtonTextColor()
        eventSearchButton.layer.cornerRadius = self.theme.eventsGoButtonCornerRadius()
        
        zipCodeTextField.autoPinEdgeToSuperviewEdge(.Top, withInset: 8)
        zipCodeTextField.autoPinEdgeToSuperviewEdge(.Left, withInset: 8)
        zipCodeTextField.placeholder = NSLocalizedString("Events_zipCodeTextBoxPlaceholder",  comment: "")
        zipCodeTextField.keyboardType = .NumberPad
        zipCodeTextField.textColor = self.theme.eventsZipCodeTextColor()
        zipCodeTextField.font = self.theme.eventsZipCodeFont()
        zipCodeTextField.backgroundColor = self.theme.eventsZipCodeBackgroundColor()
        zipCodeTextField.layer.borderColor = self.theme.eventsZipCodeBorderColor().CGColor
        zipCodeTextField.layer.borderWidth = self.theme.eventsZipCodeBorderWidth()
        zipCodeTextField.layer.cornerRadius = self.theme.eventsZipCodeCornerRadius()
        zipCodeTextField.layer.sublayerTransform = self.theme.eventsZipCodeTextOffset()
        
        eventSearchButton.autoPinEdgeToSuperviewEdge(.Top, withInset: 8)
        eventSearchButton.autoSetDimension(.Width, toSize: 70)
        eventSearchButton.autoPinEdge(.Left, toEdge: .Right, ofView: zipCodeTextField, withOffset: 8)
        eventSearchButton.autoPinEdgeToSuperviewEdge(.Right, withInset: 8)
        eventSearchButton.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: zipCodeTextField)
        
        resultsTableView.autoPinEdge(.Top, toEdge: .Bottom, ofView: zipCodeTextField, withOffset: 8)
        resultsTableView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Top)
        
        noResultsLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: zipCodeTextField, withOffset: 16)
        noResultsLabel.autoPinEdgeToSuperviewEdge(.Left)
        noResultsLabel.autoPinEdgeToSuperviewEdge(.Right)
        noResultsLabel.textAlignment = .Center
        noResultsLabel.text = NSLocalizedString("Events_noEventsFound", comment: "")
        noResultsLabel.textColor = self.theme.eventsNoResultsTextColor()
        noResultsLabel.font = self.theme.eventsNoResultsFont()
        noResultsLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail;
        
        loadingActivityIndicatorView.autoPinEdge(.Top, toEdge: .Bottom, ofView: zipCodeTextField, withOffset: 16)
        loadingActivityIndicatorView.autoAlignAxisToSuperviewAxis(.Vertical)
        loadingActivityIndicatorView.color = self.theme.defaultSpinnerColor()

        resultsTableView.hidden = true
        noResultsLabel.hidden = true
        loadingActivityIndicatorView.hidesWhenStopped = true
        loadingActivityIndicatorView.stopAnimating()
    }
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    // MARK: <UITableViewDataSource>
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell") as! EventListTableViewCell
        let event = events[indexPath.row]
        
        cell.addressLabel.textColor = self.theme.eventsListColor()
        cell.addressLabel.font = self.theme.eventsListFont()
        cell.attendeesLabel.textColor = self.theme.eventsListColor()
        cell.attendeesLabel.font = self.theme.eventsListFont()
        cell.nameLabel.textColor = self.theme.eventsListColor()
        cell.nameLabel.font = self.theme.eventsListFont()
        
        return self.eventPresenter.presentEvent(event, cell: cell)
    }
    
    // MARK: <UITableViewDelegate>
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let event = self.events[indexPath.row]
        let controller = self.eventControllerProvider.provideInstanceWithEvent(event)

        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: Actions
    
    func didTapSettings() {
        self.navigationController?.pushViewController(self.settingsController, animated: true)
    }
    
    func didTapSearch(sender : UIButton!) {
        self.zipCodeTextField.resignFirstResponder()
        resultsTableView.hidden = true
        noResultsLabel.hidden = true
        loadingActivityIndicatorView.hidden = false
        loadingActivityIndicatorView.startAnimating()
        
        self.eventRepository.fetchEventsWithZipCode(self.zipCodeTextField.text, radiusMiles: 50.0,
            completion: { (events: Array<Event>) -> Void in
                var matchingEventsFound = events.count > 0
                self.events = events

                self.noResultsLabel.hidden = matchingEventsFound
                self.resultsTableView.hidden = !matchingEventsFound
                self.loadingActivityIndicatorView.stopAnimating()
                
                self.resultsTableView.reloadData()  // TODO: test me
            }) { (error: NSError) -> Void in
                self.noResultsLabel.hidden = false
                self.loadingActivityIndicatorView.stopAnimating()
        }
    }
}
