import UIKit
import PureLayout
import QuartzCore

// swiftlint:disable type_body_length

class EventsController: UIViewController {
    let eventRepository: EventRepository
    let eventPresenter: EventPresenter
    private let eventControllerProvider: EventControllerProvider
    private let eventSectionHeaderPresenter: EventSectionHeaderPresenter
    private let analyticsService: AnalyticsService
    private let tabBarItemStylist: TabBarItemStylist
    private let eventListTableViewCellStylist: EventListTableViewCellStylist
    private let theme: Theme

    let zipCodeTextField = UITextField.newAutoLayoutView()
    let radiusButton = ResponderButton.newAutoLayoutView()
    let radiusPickerView = UIPickerView()
    let resultsTableView = UITableView.newAutoLayoutView()
    let noResultsLabel = UILabel.newAutoLayoutView()
    let instructionsLabel = UILabel.newAutoLayoutView()
    let loadingActivityIndicatorView = UIActivityIndicatorView.newAutoLayoutView()

    private let radiusPickerViewOptions = [5, 10, 20, 50, 100, 250]
    private var selectedSearchRadiusIndex = 1
    private var previouslySelectedRow: Int!
    private var eventSearchResult: EventSearchResult!


    init(eventRepository: EventRepository,
        eventPresenter: EventPresenter,
        eventControllerProvider: EventControllerProvider,
        eventSectionHeaderPresenter: EventSectionHeaderPresenter,
        analyticsService: AnalyticsService,
        tabBarItemStylist: TabBarItemStylist,
        eventListTableViewCellStylist: EventListTableViewCellStylist,
        theme: Theme) {

        self.eventRepository = eventRepository
        self.eventPresenter = eventPresenter
        self.eventControllerProvider = eventControllerProvider
        self.eventSectionHeaderPresenter = eventSectionHeaderPresenter
        self.analyticsService = analyticsService
        self.tabBarItemStylist = tabBarItemStylist
        self.eventListTableViewCellStylist = eventListTableViewCellStylist
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

        radiusButton.addTarget(self, action: "didTapRadius", forControlEvents: .TouchUpInside)
        radiusButton.buttonInputView = radiusPickerView

        radiusPickerView.showsSelectionIndicator = true

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

    override func viewDidAppear(animated: Bool) {
        self.previouslySelectedRow = selectedSearchRadiusIndex
        radiusPickerView.selectRow(self.selectedSearchRadiusIndex, inComponent: 0, animated: false)
        radiusPickerView.reloadAllComponents()
    }

    // MARK: Actions

    func didTapRadius() {
        self.previouslySelectedRow = self.radiusPickerView.selectedRowInComponent(0)
        self.radiusButton.becomeFirstResponder()
    }

    func didTapSearch(sender: UIButton!) {
        let enteredZipCode = self.zipCodeTextField.text!
        self.analyticsService.trackSearchWithQuery(enteredZipCode, context: .Events)

        zipCodeTextField.resignFirstResponder()
        radiusButton.resignFirstResponder()

        self.instructionsLabel.hidden = true
        self.resultsTableView.hidden = true
        self.noResultsLabel.hidden = true

        loadingActivityIndicatorView.startAnimating()

        self.eventRepository.fetchEventsWithZipCode(enteredZipCode, radiusMiles: Float(self.radiusPickerViewOptions[self.selectedSearchRadiusIndex]),
            completion: { (eventSearchResult: EventSearchResult) -> Void in
                let matchingEventsFound = eventSearchResult.events.count > 0
                self.radiusButton.hidden = false
                self.eventSearchResult = eventSearchResult

                self.noResultsLabel.hidden = matchingEventsFound
                self.resultsTableView.hidden = !matchingEventsFound
                self.loadingActivityIndicatorView.stopAnimating()

                self.resultsTableView.reloadData()
            }) { (error: NSError) -> Void in
                self.radiusButton.hidden = false
                self.analyticsService.trackError(error, context: "Events")
                self.noResultsLabel.hidden = false
                self.loadingActivityIndicatorView.stopAnimating()
        }
    }

    func didTapCancel(sender: UIButton!) {
        self.analyticsService.trackCustomEventWithName("Cancelled ZIP Code search on Events", customAttributes: nil)
        self.zipCodeTextField.resignFirstResponder()
        self.radiusButton.resignFirstResponder()
        self.radiusPickerView.selectRow(self.previouslySelectedRow, inComponent: 0, animated: false)
        self.selectedSearchRadiusIndex = self.previouslySelectedRow
    }

    // MARK: Private

    func setupSubviews() {
        view.addSubview(zipCodeTextField)
        view.addSubview(radiusButton)
        view.addSubview(instructionsLabel)
        view.addSubview(resultsTableView)
        view.addSubview(noResultsLabel)
        view.addSubview(loadingActivityIndicatorView)

        zipCodeTextField.delegate = self
        zipCodeTextField.placeholder = NSLocalizedString("Events_zipCodeTextBoxPlaceholder",  comment: "")
        zipCodeTextField.keyboardType = .NumberPad

        radiusButton.setTitle("Radius", forState: .Normal)
        radiusButton.setTitleColor(self.theme.eventsZipCodeTextColor(), forState: .Normal)
        radiusPickerView.delegate = self
        radiusPickerView.dataSource = self

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
        radiusButton.buttonInputAccessoryView = inputAccessoryView
    }

    func applyTheme() {
        zipCodeTextField.textColor = self.theme.eventsZipCodeTextColor()
        zipCodeTextField.font = self.theme.eventsZipCodeFont()
        zipCodeTextField.backgroundColor = self.theme.eventsZipCodeBackgroundColor()
        zipCodeTextField.layer.borderColor = self.theme.eventsZipCodeBorderColor().CGColor
        zipCodeTextField.layer.borderWidth = self.theme.eventsZipCodeBorderWidth()
        zipCodeTextField.layer.cornerRadius = self.theme.eventsZipCodeCornerRadius()
        zipCodeTextField.layer.sublayerTransform = self.theme.eventsZipCodeTextOffset()

        radiusButton.backgroundColor = self.theme.eventsZipCodeBackgroundColor()
        radiusButton.layer.borderColor = self.theme.eventsZipCodeBorderColor().CGColor
        radiusButton.layer.borderWidth = self.theme.eventsZipCodeBorderWidth()
        radiusButton.layer.cornerRadius = self.theme.eventsZipCodeCornerRadius()
        radiusButton.layer.sublayerTransform = self.theme.eventsZipCodeTextOffset()

        instructionsLabel.font = theme.eventsInstructionsFont()
        instructionsLabel.textColor = theme.eventsInstructionsTextColor()

        noResultsLabel.textColor = self.theme.eventsNoResultsTextColor()
        noResultsLabel.font = self.theme.eventsNoResultsFont()

        loadingActivityIndicatorView.color = self.theme.defaultSpinnerColor()
    }

    func setupConstraints() {
        zipCodeTextField.autoPinEdgeToSuperviewEdge(.Top, withInset: 24)
        zipCodeTextField.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        zipCodeTextField.autoPinEdgeToSuperviewEdge(.Right, withInset: 80)
        zipCodeTextField.autoSetDimension(.Height, toSize: 45)

        radiusButton.autoPinEdge(.Left, toEdge: .Right, ofView: zipCodeTextField, withOffset: 8)
        radiusButton.autoAlignAxis(.Horizontal, toSameAxisOfView: zipCodeTextField)
        radiusButton.autoSetDimension(.Height, toSize: 45)
        radiusButton.autoSetDimension(.Width, toSize: 60)

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

// swiftlint:enable type_body_length


// MARK: <UITableViewDataSource>
extension EventsController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return eventSearchResult != nil ? eventSearchResult.uniqueDaysInLocalTimeZone().count : 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventSearchResult != nil ? eventSearchResult.eventsWithDayIndex(section).count : 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell") as! EventListTableViewCell
        // swiftlint:enable force_cast

        let eventsForDay = eventSearchResult.eventsWithDayIndex(indexPath.section)
        let event = eventsForDay[indexPath.row]

        self.eventListTableViewCellStylist.styleCell(cell, event: event)

        return self.eventPresenter.presentEventListCell(event, searchCentroid: eventSearchResult.searchCentroid, cell: cell)
    }
}

// MARK: <UITableViewDelegate>
extension EventsController: UITableViewDelegate {
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if eventSearchResult == nil {
            return nil
        }

        let sectionDate = self.eventSearchResult.uniqueDaysInLocalTimeZone()[section]
        return self.eventSectionHeaderPresenter.headerForDate(sectionDate)
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let eventsForDay = eventSearchResult.eventsWithDayIndex(indexPath.section)
        let event = eventsForDay[indexPath.row]
        let controller = self.eventControllerProvider.provideInstanceWithEvent(event)
        self.analyticsService.trackContentViewWithName(event.name, type: .Event, id: event.url.absoluteString)
        self.navigationController?.pushViewController(controller, animated: true)
    }

    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        headerView.contentView.backgroundColor = self.theme.eventsListSectionHeaderBackgroundColor()
        headerView.textLabel?.textColor = self.theme.eventsListSectionHeaderTextColor()
        headerView.textLabel?.font = self.theme.eventsListSectionHeaderFont()
    }
}

// MARK: <UITextFieldDelegate>
extension EventsController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        self.analyticsService.trackCustomEventWithName("Tapped on ZIP Code text field on Events", customAttributes: nil)
    }
}

// MARK: <UIPickerViewDataSource>

extension EventsController: UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 6
    }
}

// MARK: <UIPickerViewDelegate>

extension EventsController: UIPickerViewDelegate {

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return NSString.localizedStringWithFormat(NSLocalizedString("Events_radiusMiles", comment: ""), self.radiusPickerViewOptions[row]) as String
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedSearchRadiusIndex = row
    }
}
