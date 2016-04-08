import UIKit

protocol EventsNearAddressSearchBarControllerDelegate {
    func eventsNearAddressSearchBarControllerDidBeginEditing(controller: EventsNearAddressSearchBarController)
    func eventsNearAddressSearchBarControllerDidBeginFiltering(controller: EventsNearAddressSearchBarController)
}

class EventsNearAddressSearchBarController: UIViewController {
    private let searchBarStylist: SearchBarStylist
    private let eventsNearAddressUseCase: EventsNearAddressUseCase
    private let resultQueue: NSOperationQueue
    private let radiusDataSource: RadiusDataSource
    private let analyticsService: AnalyticsService
    private let theme: Theme

    let searchBar = UISearchBar.newAutoLayoutView()
    let filterLabel = UILabel.newAutoLayoutView()
    let filterButton = ResponderButton.newAutoLayoutView()
    let filterDownArrow = UIImageView.newAutoLayoutView()

    private let leftFilterSpacerView = UIView.newAutoLayoutView()
    private let rightFilterSpacerView = UIView.newAutoLayoutView()

    var delegate: EventsNearAddressSearchBarControllerDelegate?

    init(searchBarStylist: SearchBarStylist,
        eventsNearAddressUseCase: EventsNearAddressUseCase,
        resultQueue: NSOperationQueue,
        radiusDataSource: RadiusDataSource,
        analyticsService: AnalyticsService,
        theme: Theme) {
        self.searchBarStylist = searchBarStylist
        self.eventsNearAddressUseCase = eventsNearAddressUseCase
        self.resultQueue = resultQueue
        self.radiusDataSource = radiusDataSource
        self.analyticsService = analyticsService
        self.theme = theme

        super.init(nibName: nil, bundle: nil)

        eventsNearAddressUseCase.addObserver(self)
        radiusDataSource.addObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.clipsToBounds = true
        view.addSubview(searchBar)
        view.addSubview(filterLabel)
        view.addSubview(filterButton)
        view.addSubview(filterDownArrow)
        view.addSubview(leftFilterSpacerView)
        view.addSubview(rightFilterSpacerView)

        filterDownArrow.image = UIImage(named: "downArrow")

        searchBarStylist.applyThemeToSearchBar(searchBar)
        searchBarStylist.applyThemeToBackground(view)

        searchBar.placeholder = NSLocalizedString("EventsSearchBar_searchBarPlaceholder", comment: "")
        searchBar.accessibilityLabel = NSLocalizedString("EventsSearchBar_searchBarAccessibilityLabel", comment: "")
        searchBar.delegate = self

        filterLabel.text = NSLocalizedString("EventsSearchBar_filterLabel", comment: "")

        let currentRadiusMilesInteger = Int(radiusDataSource.currentMilesValue)
        filterButton.setTitle(NSString.localizedStringWithFormat(NSLocalizedString("EventsSearchBar_filterButton %d", comment: ""), currentRadiusMilesInteger) as String, forState: .Normal)
        filterButton.addTarget(self, action: #selector(EventsNearAddressSearchBarController.didTapFilterButton), forControlEvents: .TouchUpInside)

        applyTheme()
        setupConstraints()
    }

    private func setupConstraints() {
        searchBar.autoPinEdgeToSuperviewEdge(.Top, withInset: theme.eventSearchBarSearchBarTopPadding())
        searchBar.autoPinEdgeToSuperviewEdge(.Left, withInset: -theme.eventSearchBarHorizontalPadding())
        searchBar.autoPinEdgeToSuperviewEdge(.Right, withInset: -theme.eventSearchBarHorizontalPadding())

        if let searchBarContainer = searchBar.subviews.first {
            searchBarContainer.autoAlignAxis(.Horizontal, toSameAxisOfView: searchBar, withOffset: theme.eventSearchBarVerticalShift())
            searchBarContainer.autoPinEdgeToSuperviewEdge(.Left, withInset: theme.eventSearchBarHorizontalPadding())
            searchBarContainer.autoPinEdgeToSuperviewEdge(.Right, withInset: theme.eventSearchBarHorizontalPadding())
            searchBarContainer.autoSetDimension(.Height, toSize: theme.eventSearchBarSearchBarHeight())
        }

        if let textField = searchBar.valueForKey("searchField") as? UITextField {
            textField.autoAlignAxis(.Horizontal, toSameAxisOfView: self.searchBar, withOffset: theme.eventSearchBarVerticalShift())
            textField.autoPinEdgeToSuperviewEdge(.Left, withInset: theme.eventSearchBarHorizontalPadding())
            textField.autoPinEdgeToSuperviewEdge(.Right, withInset: theme.eventSearchBarHorizontalPadding())
            textField.autoSetDimension(.Height, toSize: theme.eventSearchBarSearchBarHeight())
        }

        if let background = searchBar.valueForKey("background") as? UIView {
            background.autoAlignAxis(.Horizontal, toSameAxisOfView: self.searchBar, withOffset: theme.eventSearchBarVerticalShift())
            background.autoPinEdgeToSuperviewEdge(.Left)
            background.autoPinEdgeToSuperviewEdge(.Right)
            background.autoSetDimension(.Height, toSize: theme.eventSearchBarSearchBarHeight())
        }

        leftFilterSpacerView.autoPinEdgeToSuperviewEdge(.Left)
        leftFilterSpacerView.autoSetDimension(.Width, toSize: 0, relation: .GreaterThanOrEqual)
        leftFilterSpacerView.autoAlignAxis(.Horizontal, toSameAxisOfView: filterLabel)

        filterLabel.autoPinEdge(.Left, toEdge: .Right, ofView: leftFilterSpacerView)
        filterLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: theme.eventSearchBarFilterLabelBottomPadding())

        filterButton.autoAlignAxis(.Horizontal, toSameAxisOfView: filterLabel)
        filterButton.autoPinEdge(.Left, toEdge: .Right, ofView: filterLabel, withOffset: 2)

        filterDownArrow.autoAlignAxis(.Horizontal, toSameAxisOfView: filterLabel, withOffset: 1)
        filterDownArrow.autoPinEdge(.Left, toEdge: .Right, ofView: filterButton, withOffset: 2)

        rightFilterSpacerView.autoPinEdge(.Left, toEdge: .Right, ofView: filterDownArrow)
        rightFilterSpacerView.autoPinEdgeToSuperviewEdge(.Right)
        rightFilterSpacerView.autoMatchDimension(.Width, toDimension: .Width, ofView: leftFilterSpacerView)
        rightFilterSpacerView.autoAlignAxis(.Horizontal, toSameAxisOfView: filterLabel)
    }

    private func applyTheme() {
        filterButton.setTitleColor(theme.eventsFilterButtonTextColor(), forState: .Normal)
        filterButton.titleLabel!.font = theme.eventsFilterLabelFont()
        filterLabel.textColor = theme.eventsFilterLabelTextColor()
        filterLabel.font = theme.eventsFilterLabelFont()
    }
}

// MARK: Actions

extension EventsNearAddressSearchBarController {
    func didTapFilterButton() {
        analyticsService.trackCustomEventWithName("Tapped on filter button on Events Near Address", customAttributes: nil)
        delegate?.eventsNearAddressSearchBarControllerDidBeginFiltering(self)
    }
}

// MARK: UISearchBarDelegate
extension EventsNearAddressSearchBarController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        analyticsService.trackCustomEventWithName("Tapped on address search bar on Events Near Address", customAttributes: nil)
        delegate?.eventsNearAddressSearchBarControllerDidBeginEditing(self)

        return false
    }
}

// MARK: EventsNearAddressUseCaseObserver
extension EventsNearAddressSearchBarController: EventsNearAddressUseCaseObserver {
    func eventsNearAddressUseCaseFoundNoEvents(useCase: EventsNearAddressUseCase, address: Address) {

    }

    func eventsNearAddressUseCaseDidStartFetchingEvents(useCase: EventsNearAddressUseCase, address: Address) {
        resultQueue.addOperationWithBlock {
            if let textField = self.searchBar.valueForKey("searchField") as? UITextField {
                textField.attributedPlaceholder = NSAttributedString(string: address, attributes: [NSForegroundColorAttributeName: self.theme.eventsAddressTextColor()])
            }
        }
    }

    func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFetchEventSearchResult eventSearchResult: EventSearchResult, address: Address) {

    }

    func eventsNearAddressUseCase(useCase: EventsNearAddressUseCase, didFailFetchEvents error: EventsNearAddressUseCaseError, address: Address) {

    }
}

// MARK RadiusDataSourceObserver
extension EventsNearAddressSearchBarController: RadiusDataSourceObserver {
    func radiusDataSourceDidUpdateRadiusMiles(radiusMiles: Float) {
        resultQueue.addOperationWithBlock {
            let currentRadiusMilesInteger = Int(radiusMiles)
            self.filterButton.setTitle(NSString.localizedStringWithFormat(NSLocalizedString("EventsSearchBar_filterButton %d", comment: ""), currentRadiusMilesInteger) as String, forState: .Normal)
        }
    }
}
