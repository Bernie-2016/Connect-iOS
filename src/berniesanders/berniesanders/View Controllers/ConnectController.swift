import UIKit
import PureLayout

public class ConnectController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    public let eventRepository : EventRepository!
    
    public let zipCodeTextField = UITextField.newAutoLayoutView()
    public let eventSearchButton = UIButton.newAutoLayoutView()
    public let resultsTableView = UITableView.newAutoLayoutView()
    public let noResultsLabel = UILabel.newAutoLayoutView()
    
    var events: Array<Event>!
    
    public init(eventRepository: EventRepository, theme: Theme) {
        self.eventRepository = eventRepository
        self.events = []
        
        super.init(nibName: nil, bundle: nil)
        
        self.tabBarItem.setTitlePositionAdjustment(UIOffsetMake(0, -4))
        self.tabBarItem.image = UIImage(named: "connectTabBarIconInactive")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBarItem.selectedImage = UIImage(named: "connectTabBarIcon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
        let activeTabBarTextAttributes = [NSFontAttributeName: theme.tabBarFont(), NSForegroundColorAttributeName: theme.tabBarActiveTextColor()]
        let inactiveTabBarTextAttributes = [NSFontAttributeName: theme.tabBarFont(), NSForegroundColorAttributeName: theme.tabBarInactiveTextColor()]
        
        self.tabBarItem.setTitleTextAttributes(inactiveTabBarTextAttributes, forState: .Normal)
        self.tabBarItem.setTitleTextAttributes(activeTabBarTextAttributes, forState: .Selected)
        
        self.title = NSLocalizedString("Connect_tabBarTitle", comment: "")
        self.navigationItem.title = NSLocalizedString("Connect_navigationTitle", comment: "")
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resultsTableView.dataSource = self
        self.resultsTableView.delegate = self // TODO: TEST ME!
        self.resultsTableView.registerClass(EventListTableViewCell.self, forCellReuseIdentifier: "eventCell")
        
        setNeedsStatusBarAppearanceUpdate()
        
        view.backgroundColor = UIColor.redColor()
        zipCodeTextField.backgroundColor = UIColor.yellowColor()
        eventSearchButton.backgroundColor = UIColor.blueColor()
        resultsTableView.backgroundColor = UIColor.purpleColor()
        noResultsLabel.backgroundColor = UIColor.greenColor()
        
        view.addSubview(zipCodeTextField)
        view.addSubview(eventSearchButton)
        view.addSubview(resultsTableView)
        view.addSubview(noResultsLabel)
        
        eventSearchButton.addTarget(self, action: "didTapSearch:", forControlEvents: .TouchUpInside)
        
        zipCodeTextField.autoPinEdgeToSuperviewEdge(.Top, withInset: 20)
        zipCodeTextField.autoPinEdgeToSuperviewMargin(.Left)

        eventSearchButton.autoPinEdgeToSuperviewEdge(.Top, withInset: 20)
        eventSearchButton.autoPinEdge(.Left, toEdge: .Right, ofView: zipCodeTextField)
        eventSearchButton.autoPinEdgeToSuperviewMargin(.Right)
        eventSearchButton.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: zipCodeTextField)
        
        resultsTableView.autoPinEdge(.Top, toEdge: .Bottom, ofView: eventSearchButton)
        resultsTableView.autoPinEdgesToSuperviewMarginsExcludingEdge(.Top)
        
        noResultsLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: eventSearchButton)
        noResultsLabel.autoPinEdgesToSuperviewMarginsExcludingEdge(.Top)

        resultsTableView.hidden = true
        noResultsLabel.hidden = true
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
        cell.nameLabel.text = event.name
        cell.addressLabel.text = String(format: NSLocalizedString("Connect_eventAddressLabel", comment: ""), event.city, event.state, event.zip)
        cell.attendeesLabel.text = String(format: NSLocalizedString("Connect_eventAttendeeLabel", comment: ""), event.attendeeCount, event.attendeeCapacity)
        return cell
    }
    
    // MARK: <UITableViewDelegate>
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    // MARK: private
    
    func didTapSearch(sender : UIButton!) {
        resultsTableView.hidden = true
        noResultsLabel.hidden = true
        
        self.eventRepository.fetchEventsWithZipCode(self.zipCodeTextField.text, radiusMiles: 50.0,
            completion: { (events: Array<Event>) -> Void in
                var matchingEventsFound = events.count > 0
                self.events = events
                self.noResultsLabel.hidden = matchingEventsFound
                self.resultsTableView.hidden = !matchingEventsFound
                
                self.resultsTableView.reloadData()  // TODO: test me
            }) { (error: NSError) -> Void in
        }
    }
}
