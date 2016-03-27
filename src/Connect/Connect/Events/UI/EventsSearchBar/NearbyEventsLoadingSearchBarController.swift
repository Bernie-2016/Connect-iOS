import UIKit

class NearbyEventsLoadingSearchBarController: UIViewController {
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

        let currentRadiusMilesInteger = Int(radiusDataSource.currentMilesValue)
        filterLabel.text = NSString.localizedStringWithFormat(NSLocalizedString("EventsSearchBar_loadingFilterLabel %d", comment: ""), currentRadiusMilesInteger) as String

        searchBar.userInteractionEnabled = false
        searchBar.placeholder = NSLocalizedString("EventsSearchBar_loadingNearbyEvents", comment: "")

        setupConstraints()
        applyTheme()
    }

    private func setupConstraints() {
        searchBar.autoPinEdgeToSuperviewEdge(.Top, withInset: theme.eventSearchBarSearchBarTopPadding())
        searchBar.autoPinEdgeToSuperviewEdge(.Left, withInset: -theme.eventSearchBarHorizontalPadding())
        searchBar.autoPinEdgeToSuperviewEdge(.Right, withInset: -theme.eventSearchBarHorizontalPadding())

        if let searchBarContainer = searchBar.subviews.first {
            searchBarContainer.autoAlignAxis(.Horizontal, toSameAxisOfView: self.searchBar, withOffset: theme.eventSearchBarVerticalShift())
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

        filterLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: theme.eventSearchBarFilterLabelBottomPadding())
        filterLabel.autoAlignAxis(.Vertical, toSameAxisOfView: searchBar)
    }

    private func applyTheme() {
        filterLabel.textColor = theme.eventsFilterLabelTextColor()
        filterLabel.font = theme.eventsFilterLabelFont()
        searchBarStylist.applyThemeToBackground(view)
        searchBarStylist.applyThemeToSearchBar(searchBar)
    }
}

// MARK RadiusDataSourceObserver
extension NearbyEventsLoadingSearchBarController: RadiusDataSourceObserver {
    func radiusDataSourceDidUpdateRadiusMiles(radiusMiles: Float) {
        resultQueue.addOperationWithBlock {
            let currentRadiusMilesInteger = Int(radiusMiles)
            self.filterLabel.text = NSString.localizedStringWithFormat(NSLocalizedString("EventsSearchBar_loadingFilterLabel %d", comment: ""), currentRadiusMilesInteger) as String
        }
    }
}
