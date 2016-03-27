import UIKit

protocol EditAddressSearchBarControllerDelegate {
    func editAddressSearchBarControllerDidCancel(controller: EditAddressSearchBarController)
}

class EditAddressSearchBarController: UIViewController {
    private let nearbyEventsUseCase: NearbyEventsUseCase
    private let eventsNearAddressUseCase: EventsNearAddressUseCase!
    private let radiusDataSource: RadiusDataSource!
    private let zipCodeValidator: ZipCodeValidator
    private let searchBarStylist: SearchBarStylist
    private let resultQueue: NSOperationQueue
    private let workerQueue: NSOperationQueue
    private let analyticsService: AnalyticsService
    private let theme: Theme

    let searchBar = UISearchBar.newAutoLayoutView()
    let searchButton = UIButton.newAutoLayoutView()
    let cancelButton = UIButton.newAutoLayoutView()

    var delegate: EditAddressSearchBarControllerDelegate?

    private var currentSearchText = ""

    init(
        nearbyEventsUseCase: NearbyEventsUseCase,
        eventsNearAddressUseCase: EventsNearAddressUseCase,
        radiusDataSource: RadiusDataSource,
        zipCodeValidator: ZipCodeValidator,
        searchBarStylist: SearchBarStylist,
        resultQueue: NSOperationQueue,
        workerQueue: NSOperationQueue,
        analyticsService: AnalyticsService,
        theme: Theme
        ) {
            self.nearbyEventsUseCase = nearbyEventsUseCase
            self.eventsNearAddressUseCase = eventsNearAddressUseCase
            self.radiusDataSource = radiusDataSource
            self.zipCodeValidator = zipCodeValidator
            self.searchBarStylist = searchBarStylist
            self.resultQueue = resultQueue
            self.workerQueue = workerQueue
            self.analyticsService = analyticsService
            self.theme = theme

            super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.clipsToBounds = true
        view.addSubview(searchBar)
        view.addSubview(searchButton)
        view.addSubview(cancelButton)

        cancelButton.setTitle(NSLocalizedString("EventsSearchBar_cancelButtonTitle", comment: ""), forState: .Normal)
        cancelButton.addTarget(self, action: #selector(EditAddressSearchBarController.didTapCancelButton), forControlEvents: .TouchUpInside)

        searchButton.setTitle(NSLocalizedString("EventsSearchBar_searchButtonTitle", comment: ""), forState: .Normal)
        searchButton.addTarget("self", action: #selector(EditAddressSearchBarController.didTapSearchButton), forControlEvents: .TouchUpInside)
        searchButton.enabled = false

        searchBarStylist.applyThemeToBackground(view)
        searchBarStylist.applyThemeToSearchBar(searchBar)

        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("EventsSearchBar_searchBarPlaceholder", comment: "")
        searchBar.accessibilityLabel = NSLocalizedString("EventsSearchBar_searchBarAccessibilityLabel", comment: "")
        searchBar.keyboardType = .NumberPad

        nearbyEventsUseCase.addObserver(self)
        eventsNearAddressUseCase.addObserver(self)

        setupConstraints()
        applyTheme()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        searchBar.becomeFirstResponder()
    }

    private func setupConstraints() {
        let searchBarBottomPadding: CGFloat = 10
        let buttonWidth: CGFloat = 60
        let verticalShift: CGFloat = 8
        let horizontalPadding: CGFloat = 15
        let searchBarHeight: CGFloat = 34

        cancelButton.autoPinEdgeToSuperviewEdge(.Left, withInset: horizontalPadding)
        cancelButton.autoAlignAxis(.Horizontal, toSameAxisOfView: searchBar, withOffset: verticalShift)
        cancelButton.autoSetDimension(.Width, toSize: buttonWidth)

        searchButton.autoPinEdgeToSuperviewEdge(.Right, withInset: horizontalPadding)
        searchButton.autoAlignAxis(.Horizontal, toSameAxisOfView: searchBar, withOffset: verticalShift)
        searchButton.autoSetDimension(.Width, toSize: buttonWidth)

        searchBar.autoPinEdgeToSuperviewEdge(.Top, withInset: searchBarBottomPadding)
        searchButton.autoPinEdge(.Left, toEdge: .Right, ofView: self.searchBar, withOffset: horizontalPadding)
        cancelButton.autoPinEdge(.Right, toEdge: .Left, ofView: self.searchBar, withOffset: -horizontalPadding)

        if let searchBarContainer = searchBar.subviews.first {
            searchBarContainer.autoAlignAxis(.Horizontal, toSameAxisOfView: self.searchBar, withOffset: verticalShift)
            searchBarContainer.autoPinEdgeToSuperviewEdge(.Left)
            searchBarContainer.autoPinEdgeToSuperviewEdge(.Right)
            searchBarContainer.autoSetDimension(.Height, toSize: searchBarHeight)
        }

        if let textField = searchBar.valueForKey("searchField") as? UITextField {
            textField.autoAlignAxis(.Horizontal, toSameAxisOfView: self.searchBar, withOffset: verticalShift)
            textField.autoPinEdgeToSuperviewEdge(.Left)
            textField.autoPinEdgeToSuperviewEdge(.Right)

            textField.autoSetDimension(.Height, toSize: searchBarHeight)
        }

        if let background = searchBar.valueForKey("background") as? UIView {
            background.autoAlignAxis(.Horizontal, toSameAxisOfView: self.searchBar, withOffset: verticalShift)
            background.autoPinEdgeToSuperviewEdge(.Left)
            background.autoPinEdgeToSuperviewEdge(.Right)
            background.autoSetDimension(.Height, toSize: searchBarHeight)
        }
    }

    private func applyTheme() {
        searchButton.setTitleColor(theme.defaultButtonDisabledTextColor(), forState: .Disabled)
        searchButton.setTitleColor(theme.navigationBarButtonTextColor(), forState: .Normal)
        searchButton.titleLabel!.font = self.theme.eventsSearchBarFont()

        cancelButton.setTitleColor(theme.defaultButtonDisabledTextColor(), forState: .Disabled)
        cancelButton.setTitleColor(theme.navigationBarButtonTextColor(), forState: .Normal)
        cancelButton.titleLabel!.font = self.theme.eventsSearchBarFont()
    }
}

// MARK: Actions

extension EditAddressSearchBarController {
    func didTapCancelButton() {
        analyticsService.trackCustomEventWithName("Cancelled edit address on Events", customAttributes: nil)

        searchBar.text = currentSearchText
        delegate?.editAddressSearchBarControllerDidCancel(self)
    }

    func didTapSearchButton() {
        workerQueue.addOperationWithBlock {
            let searchQuery = self.searchBar.text!
            let radiusMiles = self.radiusDataSource.currentMilesValue
            let loggedSearchQuery = "\(searchQuery)|\(radiusMiles)"

            self.analyticsService.trackSearchWithQuery(loggedSearchQuery, context: .Events)
            self.eventsNearAddressUseCase.fetchEventsNearAddress(searchQuery, radiusMiles: radiusMiles)
        }
    }
}

// MARK: NearbyEventsUseCaseObserver
extension EditAddressSearchBarController: NearbyEventsUseCaseObserver {
    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFailFetchEvents: NearbyEventsUseCaseError) {

    }

    func nearbyEventsUseCase(useCase: NearbyEventsUseCase, didFetchEventSearchResult: EventSearchResult) {

    }

    func nearbyEventsUseCaseDidStartFetchingEvents(useCase: NearbyEventsUseCase) {
        resultQueue.addOperationWithBlock {
            self.currentSearchText = ""
            self.searchBar.text = ""
            self.searchButton.enabled = false
        }
    }

    func nearbyEventsUseCaseFoundNoNearbyEvents(useCase: NearbyEventsUseCase) {

    }
}

// MARK: EventsNearAddressUseCaseObserver
extension EditAddressSearchBarController: EventsNearAddressUseCaseObserver {
    func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFailFetchEvents error: EventsNearAddressUseCaseError, address: Address) {

    }

    func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFetchEventSearchResult eventSearchResult: EventSearchResult, address: Address) {

    }

    func eventsNearAddressUseCaseDidStartFetchingEvents(useCase: EventsNearAddressUseCase, address: Address) {
        resultQueue.addOperationWithBlock {
            self.currentSearchText = address
            self.searchBar.text = address
        }
    }

    func eventsNearAddressUseCaseFoundNoEvents(useCase: EventsNearAddressUseCase, address: Address) {

    }
}

// MARK: UISearchBarDelegate
extension EditAddressSearchBarController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let updatedZipCode = (searchBar.text! as NSString).stringByReplacingCharactersInRange(range, withString: text)

        if updatedZipCode.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < 6 {
            searchButton.enabled = zipCodeValidator.validate(updatedZipCode)
        }

        return updatedZipCode.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) <= 5
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            searchButton.enabled = false
        }
    }
}
