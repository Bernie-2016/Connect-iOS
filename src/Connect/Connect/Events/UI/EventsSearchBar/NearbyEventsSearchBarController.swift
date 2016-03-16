import UIKit

protocol NearbyEventsSearchBarControllerDelegate {
    func nearbyEventsSearchBarControllerDidBeginEditing(controller: NearbyEventsSearchBarController)
    func nearbyEventsSearchBarControllerDidBeginFiltering(controller: NearbyEventsSearchBarController)
}

class NearbyEventsSearchBarController: UIViewController {
    private let searchBarStylist: SearchBarStylist
    private let radiusDataSource: RadiusDataSource
    private let resultQueue: NSOperationQueue
    private let theme: Theme

    let searchBar = UISearchBar.newAutoLayoutView()
    let filterLabel = UILabel.newAutoLayoutView()
    let filterButton = ResponderButton.newAutoLayoutView()
    let filterDownArrow = UIImageView.newAutoLayoutView()

    private let leftFilterSpacerView = UIView.newAutoLayoutView()
    private let rightFilterSpacerView = UIView.newAutoLayoutView()

    var delegate: NearbyEventsSearchBarControllerDelegate?

    init(searchBarStylist: SearchBarStylist, radiusDataSource: RadiusDataSource, resultQueue: NSOperationQueue, theme: Theme) {
        self.searchBarStylist = searchBarStylist
        self.radiusDataSource = radiusDataSource
        self.resultQueue = resultQueue
        self.theme = theme

        super.init(nibName: nil, bundle: nil)

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

        searchBar.placeholder = NSLocalizedString("EventsSearchBar_foundNearbyResults", comment: "")
        searchBar.accessibilityLabel = NSLocalizedString("EventsSearchBar_searchBarAccessibilityLabel",  comment: "")
        searchBar.delegate = self

        filterLabel.text = NSLocalizedString("EventsSearchBar_filterLabel", comment: "")

        let currentRadiusMilesInteger = Int(radiusDataSource.currentMilesValue)
        filterButton.setTitle(NSString.localizedStringWithFormat(NSLocalizedString("EventsSearchBar_filterButton %d", comment: ""), currentRadiusMilesInteger) as String, forState: .Normal)
        filterButton.addTarget(self, action: "didTapFilterButton", forControlEvents: .TouchUpInside)

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

extension NearbyEventsSearchBarController {
    func didTapFilterButton() {
        delegate?.nearbyEventsSearchBarControllerDidBeginFiltering(self)
    }
}

// MARK: UISearchBarDelegate
extension NearbyEventsSearchBarController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        delegate?.nearbyEventsSearchBarControllerDidBeginEditing(self)

        return false
    }
}

// MARK RadiusDataSourceObserver
extension NearbyEventsSearchBarController: RadiusDataSourceObserver {
    func radiusDataSourceDidUpdateRadiusMiles(radiusMiles: Float) {
        resultQueue.addOperationWithBlock {
            let currentRadiusMilesInteger = Int(radiusMiles)
            self.filterButton.setTitle(NSString.localizedStringWithFormat(NSLocalizedString("EventsSearchBar_filterButton %d", comment: ""), currentRadiusMilesInteger) as String, forState: .Normal)
        }
    }
}
