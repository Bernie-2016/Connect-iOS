import UIKit
import PureLayout
import QuartzCore

class EventsController: UIViewController {
    let eventRepository: EventRepository
    let eventPresenter: EventPresenter
    private let eventControllerProvider: EventControllerProvider
    private let analyticsService: AnalyticsService
    private let tabBarItemStylist: TabBarItemStylist
    let theme: Theme

    let zipCodeTextField = UITextField.newAutoLayoutView()
    let resultsTableView = UITableView.newAutoLayoutView()
    let noResultsLabel = UILabel.newAutoLayoutView()
    let instructionsLabel = UILabel.newAutoLayoutView()
    let loadingActivityIndicatorView = UIActivityIndicatorView.newAutoLayoutView()

    var eventSearchResult: EventSearchResult!

    init(eventRepository: EventRepository,
        eventPresenter: EventPresenter,
        eventControllerProvider: EventControllerProvider,
        analyticsService: AnalyticsService,
        tabBarItemStylist: TabBarItemStylist,
        theme: Theme) {

        self.eventRepository = eventRepository
        self.eventPresenter = eventPresenter
        self.eventControllerProvider = eventControllerProvider
        self.analyticsService = analyticsService
        self.tabBarItemStylist = tabBarItemStylist
        self.theme = theme

        super.init(nibName: nil, bundle: nil)

        self.tabBarItemStylist.applyThemeToBarBarItem(self.tabBarItem,
            image: UIImage(named: "eventsTabBarIconInactive")!,
            selectedImage: UIImage(named: "eventsTabBarIcon")!)
        self.title = NSLocalizedString("Events_tabBarTitle", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("Events_navigationTitle", comment: "")
        let backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Events_backButtonTitle", comment: ""),
            style: UIBarButtonItemStyle.Plain,
            target: nil, action: nil)

        navigationItem.backBarButtonItem = backBarButtonItem

        edgesForExtendedLayout = .None
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        resultsTableView.registerClass(EventListTableViewCell.self, forCellReuseIdentifier: "eventCell")

        instructionsLabel.text = NSLocalizedString("Events_instructions", comment: "")

        setNeedsStatusBarAppearanceUpdate()

        self.setupSubviews()
        self.applyTheme()
        self.setupConstraints()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedRowIndexPath = self.resultsTableView.indexPathForSelectedRow {
            self.resultsTableView.deselectRowAtIndexPath(selectedRowIndexPath, animated: false)
        }
    }

    // MARK: Actions

    func didTapSearch(sender: UIButton!) {
        let enteredZipCode = self.zipCodeTextField.text!
        self.analyticsService.trackSearchWithQuery(enteredZipCode, context: .Events)

        zipCodeTextField.resignFirstResponder()

        self.instructionsLabel.hidden = true
        self.resultsTableView.hidden = true
        self.noResultsLabel.hidden = true

        loadingActivityIndicatorView.startAnimating()

        self.eventRepository.fetchEventsWithZipCode(enteredZipCode, radiusMiles: 50.0,
            completion: { (eventSearchResult: EventSearchResult) -> Void in
                let matchingEventsFound = eventSearchResult.events.count > 0
                self.eventSearchResult = eventSearchResult

                self.noResultsLabel.hidden = matchingEventsFound
                self.resultsTableView.hidden = !matchingEventsFound
                self.loadingActivityIndicatorView.stopAnimating()

                self.resultsTableView.reloadData()
            }) { (error: NSError) -> Void in
                self.analyticsService.trackError(error, context: "Events")
                self.noResultsLabel.hidden = false
                self.loadingActivityIndicatorView.stopAnimating()
        }
    }

    func didTapCancel(sender: UIButton!) {
        self.analyticsService.trackCustomEventWithName("Cancelled ZIP Code search on Events", customAttributes: nil)
        self.zipCodeTextField.resignFirstResponder()
    }

    // MARK: Private

    func setupSubviews() {
        view.addSubview(zipCodeTextField)
        view.addSubview(instructionsLabel)
        view.addSubview(resultsTableView)
        view.addSubview(noResultsLabel)
        view.addSubview(loadingActivityIndicatorView)

        zipCodeTextField.delegate = self
        zipCodeTextField.placeholder = NSLocalizedString("Events_zipCodeTextBoxPlaceholder",  comment: "")
        zipCodeTextField.keyboardType = .NumberPad

        instructionsLabel.textAlignment = .Center
        instructionsLabel.numberOfLines = 0
        noResultsLabel.textAlignment = .Center
        noResultsLabel.text = NSLocalizedString("Events_noEventsFound", comment: "")
        noResultsLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail;

        resultsTableView.hidden = true
        noResultsLabel.hidden = true
        loadingActivityIndicatorView.hidesWhenStopped = true
        loadingActivityIndicatorView.stopAnimating()

        let inputAccessoryView = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        inputAccessoryView.barTintColor = self.theme.eventsInputAccessoryBackgroundColor()

        let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let searchButton = UIBarButtonItem(title: NSLocalizedString("Events_eventSearchButtonTitle", comment: ""), style: .Done, target: self, action: "didTapSearch:")
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("Events_eventCancelButtonTitle", comment: ""), style: .Done, target: self, action: "didTapCancel:")

        let inputAccessoryItems = [spacer, searchButton, cancelButton]
        inputAccessoryView.items = inputAccessoryItems

        zipCodeTextField.inputAccessoryView = inputAccessoryView
    }

    func applyTheme() {
        zipCodeTextField.textColor = self.theme.eventsZipCodeTextColor()
        zipCodeTextField.font = self.theme.eventsZipCodeFont()
        zipCodeTextField.backgroundColor = self.theme.eventsZipCodeBackgroundColor()
        zipCodeTextField.layer.borderColor = self.theme.eventsZipCodeBorderColor().CGColor
        zipCodeTextField.layer.borderWidth = self.theme.eventsZipCodeBorderWidth()
        zipCodeTextField.layer.cornerRadius = self.theme.eventsZipCodeCornerRadius()
        zipCodeTextField.layer.sublayerTransform = self.theme.eventsZipCodeTextOffset()

        instructionsLabel.font = theme.eventsInstructionsFont()
        instructionsLabel.textColor = theme.eventsInstructionsTextColor()

        noResultsLabel.textColor = self.theme.eventsNoResultsTextColor()
        noResultsLabel.font = self.theme.eventsNoResultsFont()

        loadingActivityIndicatorView.color = self.theme.defaultSpinnerColor()
    }

    func setupConstraints() {
        zipCodeTextField.autoPinEdgeToSuperviewEdge(.Top, withInset: 24)
        zipCodeTextField.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        zipCodeTextField.autoPinEdgeToSuperviewEdge(.Right, withInset: 20)
        zipCodeTextField.autoSetDimension(.Height, toSize: 45)

        instructionsLabel.autoAlignAxisToSuperviewAxis(.Vertical)
        instructionsLabel.autoAlignAxisToSuperviewAxis(.Horizontal)
        instructionsLabel.autoSetDimension(.Width, toSize: 220)

        resultsTableView.autoPinEdge(.Top, toEdge: .Bottom, ofView: zipCodeTextField, withOffset: 8)
        resultsTableView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Top)

        noResultsLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: zipCodeTextField, withOffset: 16)
        noResultsLabel.autoPinEdgeToSuperviewEdge(.Left)
        noResultsLabel.autoPinEdgeToSuperviewEdge(.Right)

        loadingActivityIndicatorView.autoAlignAxisToSuperviewAxis(.Horizontal)
        loadingActivityIndicatorView.autoAlignAxisToSuperviewAxis(.Vertical)
    }
}

// MARK: <UITableViewDataSource>
extension EventsController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventSearchResult != nil ? eventSearchResult.events.count : 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell") as! EventListTableViewCell
        // swiftlint:enable force_cast

        let event = eventSearchResult.events[indexPath.row]

        cell.nameLabel.textColor = self.theme.eventsListNameColor()
        cell.nameLabel.font = self.theme.eventsListNameFont()
        cell.distanceLabel.textColor = self.theme.eventsListDistanceColor()
        cell.distanceLabel.font = self.theme.eventsListDistanceFont()

        return self.eventPresenter.presentEvent(event, searchCentroid: eventSearchResult.searchCentroid, cell: cell)
    }
}

// MARK: <UITableViewDelegate>
extension EventsController: UITableViewDelegate {
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let event = eventSearchResult.events[indexPath.row]
        let controller = self.eventControllerProvider.provideInstanceWithEvent(event)
        self.analyticsService.trackContentViewWithName(event.name, type: .Event, id: event.url.absoluteString)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: <UITextFieldDelegate>
extension EventsController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        self.analyticsService.trackCustomEventWithName("Tapped on ZIP Code text field on Events", customAttributes: nil)
    }
}
